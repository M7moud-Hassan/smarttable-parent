# يربط ملفَّي إشعارات iOS بمشروع Xcode.
#
# الخطوتان تُعملان عادة بالسحب داخل Xcode، ولا Mac هنا: البناء يجري على
# Codemagic. فتُعملان من CI بدل تعديل project.pbxproj يدويًا — كي لا يُفسد
# تعديلٌ أعمى ملفَّ مشروعٍ لا نملك أداة تتحقّق منه.
#
#   ١. GoogleService-Info.plist عضوًا في هدف Runner، وإلا لم يُنسخ داخل حزمة
#      التطبيق وفشل Firebase.initializeApp وقت التشغيل.
#   ٢. Runner.entitlements مصدرًا لـ CODE_SIGN_ENTITLEMENTS، وإلا وُقّع التطبيق
#      بلا aps-environment فلم يسجّل في APNs.
#
# السكربت لا يكرّر ما فعله: إعادة تشغيله على مشروع مُعدّ لا تغيّر شيئًا.
#
#   الاستعمال:  cd ios && ruby scripts/configure_firebase.rb

require 'xcodeproj'

PROJECT     = 'Runner.xcodeproj'
TARGET      = 'Runner'
PLIST       = 'GoogleService-Info.plist'
ENTITLEMENT = 'Runner.entitlements'

abort "لم يُعثر على #{PROJECT} — شغّل السكربت من داخل مجلد ios" unless Dir.exist?(PROJECT)

project = Xcodeproj::Project.open(PROJECT)
target  = project.targets.find { |t| t.name == TARGET }
abort "لم يُعثر على هدف #{TARGET}" if target.nil?

group = project.main_group[TARGET]
abort "لم يُعثر على مجموعة #{TARGET}" if group.nil?

changed = false

# ١) GoogleService-Info.plist داخل حزمة التطبيق
if File.exist?(File.join(TARGET, PLIST))
  in_resources = target.resources_build_phase.files.any? do |build_file|
    build_file.file_ref&.path.to_s.end_with?(PLIST)
  end

  if in_resources
    puts "= #{PLIST} مربوط بهدف #{TARGET} أصلًا"
  else
    reference = group.files.find { |f| f.path.to_s.end_with?(PLIST) } ||
                group.new_reference(PLIST)
    target.resources_build_phase.add_file_reference(reference)
    changed = true
    puts "+ أُضيف #{PLIST} إلى موارد هدف #{TARGET}"
  end
else
  abort "!! #{TARGET}/#{PLIST} غير موجود — نزّله من Firebase (مشروع smarttable-44f51) " \
        "وضعه في ios/#{TARGET}/ ثم ارفعه إلى المستودع"
end

# ٢) صلاحية الإشعارات في التوقيع
if File.exist?(File.join(TARGET, ENTITLEMENT))
  group.new_reference(ENTITLEMENT) unless group.files.any? { |f| f.path.to_s.end_with?(ENTITLEMENT) }

  target.build_configurations.each do |config|
    path = "#{TARGET}/#{ENTITLEMENT}"
    next if config.build_settings['CODE_SIGN_ENTITLEMENTS'] == path

    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = path
    changed = true
    puts "+ CODE_SIGN_ENTITLEMENTS = #{path} في #{config.name}"
  end
else
  abort "!! #{TARGET}/#{ENTITLEMENT} غير موجود"
end

if changed
  project.save
  puts 'تم حفظ مشروع Xcode'
else
  puts 'لا جديد — المشروع مُعدّ سلفًا'
end
