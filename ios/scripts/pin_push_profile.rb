# يثبّت على مشروع Xcode الـ provisioning profile المطلوب بالاسم.
#
# ترك الاختيار للتوفيق لا يصلح: على آلة البناء أكثر من profile يطابق التطبيق
# — منها قديمٌ سبق تفعيل خاصية Push، ومنها wildcard يطابق كل معرّف. فيقع
# الاختيار على أحدها فيوقَّع التطبيق بلا aps-environment، ويبدو كل شيء سليمًا
# في سجلّ البناء بينما يرفض iOS تسجيل الجهاز عند التشغيل بلا سبب ظاهر:
#   no valid "aps-environment" entitlement string found for application
#
# فيُسمّى المطلوب صراحةً، ويُتحقّق قبل البناء من أنه موجود وأنه يطابق معرّف
# الحزمة وأنه يحمل الخاصية. وإن اختلّ شرط وقف البناء بدل أن تُرفع نسخةٌ إلى
# TestFlight لا تصلها إشعارات.
#
#   الاستعمال:  cd ios && ruby scripts/pin_push_profile.rb <bundle_id> [اسم الـ profile]

require 'xcodeproj'
require 'tmpdir'

BUNDLE_ID = ARGV[0].to_s
WANTED    = ARGV[1].to_s   # اختياري: إن خلا انتُقي أول مطابقٍ حاملٍ للخاصية
abort '!! مرّر معرّف الحزمة وسيطًا' if BUNDLE_ID.empty?

PROJECT = 'Runner.xcodeproj'
TARGET  = 'Runner'
DIR     = File.expand_path('~/Library/MobileDevice/Provisioning Profiles')

# الملف موقَّع بصيغة CMS؛ يُفكّ إلى plist ثم تُقرأ حقوله بـ plutil، فلا يعتمد
# السكربت على جوهرة تحليل قد لا تكون مثبَّتة على آلة البناء.
def profile_fields(path)
  Dir.mktmpdir do |dir|
    plist = File.join(dir, 'profile.plist')
    system(%(security cms -D -i "#{path}" -o "#{plist}" 2>/dev/null))
    return nil unless File.exist?(plist) && File.size(plist) > 0

    read = lambda do |key|
      value = `plutil -extract #{key} raw -o - "#{plist}" 2>/dev/null`.strip
      value.empty? ? nil : value
    end

    return {
      name:   read.call('Name') || '(بلا اسم)',
      app_id: read.call('Entitlements.application-identifier').to_s,
      aps:    read.call('Entitlements.aps-environment'),
      path:   path
    }
  end
end

paths = Dir.glob(File.join(DIR, '*.mobileprovision'))
abort "!! لا توجد provisioning profiles في #{DIR}" if paths.empty?

profiles = paths.map { |p| profile_fields(p) }.compact

puts "الـ profiles المركَّبة على آلة البناء (#{profiles.size}):"
profiles.each do |f|
  # application-identifier = TEAMID.bundle.id — والمنتهي بنقطةٍ ونجمة wildcard.
  exact = f[:app_id].end_with?(".#{BUNDLE_ID}")
  puts format('  %-40s  مطابق=%-5s  Push=%s',
              f[:name], exact, f[:aps] || 'لا')
end

chosen =
  if WANTED.empty?
    profiles.find { |f| f[:app_id].end_with?(".#{BUNDLE_ID}") && f[:aps] }
  else
    profiles.find { |f| f[:name] == WANTED }
  end

if chosen.nil?
  abort <<~MSG

    !! #{WANTED.empty? ? "لا profile يطابق #{BUNDLE_ID} ويحمل خاصية Push" :
                         "لا يوجد profile اسمه «#{WANTED}» بين المسرودة أعلاه"}.

    راجع الاسم في Codemagic ← Code signing identities، وفي حساب أبل.
    والأسماء أعلاه هي ما تراه آلة البناء فعلًا لا ما في الحساب.
  MSG
end

unless chosen[:app_id].end_with?(".#{BUNDLE_ID}")
  abort "!! «#{chosen[:name]}» معرّفه #{chosen[:app_id]} ولا يطابق #{BUNDLE_ID}"
end

if chosen[:aps].nil?
  abort <<~MSG

    !! «#{chosen[:name]}» لا يحمل aps-environment — التطبيق الموقَّع به لن
       يُسجَّل في APNs مهما صحّ ما عداه.

    على developer.apple.com:
      ١. Identifiers ← #{BUNDLE_ID} ← فعّل Push Notifications ← Save
      ٢. Profiles ← «#{chosen[:name]}» ← Edit ← Save (يُعاد توليده حاملًا الخاصية)
      ٣. أعد جلبه في Codemagic ثم أعد البناء
  MSG
end

puts "→ سيُوقَّع بـ «#{chosen[:name]}» (aps-environment = #{chosen[:aps]})"

project = Xcodeproj::Project.open(PROJECT)
target  = project.targets.find { |t| t.name == TARGET } or abort "!! لا هدف #{TARGET}"

target.build_configurations.each do |config|
  config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = chosen[:name]
  config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
  # ولا تُترك صيغةٌ شرطية تتغلّب على ما ثُبّت للتوّ.
  config.build_settings.delete('PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]')
  config.build_settings.delete('DEVELOPMENT_TEAM[sdk=iphoneos*]')
end

project.save
puts 'تم تثبيت الـ profile على كل إعدادات البناء'
