# rake android[common/device]
describe 'common/device' do
  # Not yet implemented
  t 'shake' do
    # TODO: write test
  end

  t 'remove & install' do
    # TODO: write test
    # remove 'com.example.android.apis'
    # install ENV['APP_PATH']
  end

  t 'get_performance_data_types' do
    expected = %w(batteryinfo cpuinfo memoryinfo networkinfo)
    get_performance_data_types.sort.must_equal expected

    get_performance_data(package_name: 'io.appium.android.apis',
                         data_type: 'cpuinfo').must_equal [%w(user kernel), %w(0 0)]
  end

  t 'device_time' do
    Date.parse(device_time)
  end

  t 'get_system_bars' do
    get_system_bars
  end

  t 'get_display_density' do
    (get_display_density > 0).must_equal true
  end

  t 'system_bars' do
    is_keyboard_shown.must_equal false
  end

  t 'background_app' do
    wait { background_app 5 }
  end

  t 'start_activity' do
    wait { current_activity.must_equal '.ApiDemos' }
    start_activity app_package: 'io.appium.android.apis',
                   app_activity: '.accessibility.AccessibilityNodeProviderActivity'
    wait { current_activity.include?('Node').must_equal true }
    start_activity app_package:      'com.android.settings', app_activity:      '.Settings',
                   app_wait_package: 'com.android.settings', app_wait_activity: '.Settings'
    wait { current_activity.include?('Settings').must_equal true }
  end

  t 'current_package' do
    start_activity app_package: 'io.appium.android.apis',
                   app_activity: '.accessibility.AccessibilityNodeProviderActivity'
    wait { current_package.must_equal 'io.appium.android.apis' }
  end

  t 'installed' do
    wait { app_installed?('fake_app').must_equal false }
  end

  t 'reset' do
    reset
    wait { text(1).text.must_equal 'API Demos' }
  end

  t 'device_locked?' do
    lock 5
    wait { device_locked?.must_equal true }
    press_keycode 82
    wait { device_locked?.must_equal false }
  end

  t 'close & launch' do
    close_app
    launch_app
  end

  t 'current_activity' do
    wait { current_activity.must_equal '.ApiDemos' }
  end

  t 'app_strings' do
    wait_true { app_strings.key? 'activity_save_restore' }
  end

  def must_return_element(element)
    element.class.must_equal Selenium::WebDriver::Element
  end

  t 'press_keycode' do
    # http://developer.android.com/reference/android/view/KeyEvent.html
    press_keycode 176
  end

  t 'long_press_keycode' do
    # http://developer.android.com/reference/android/view/KeyEvent.html
    long_press_keycode 176
  end

  t 'open_notifications' do
    # test & comments from https://github.com/appium/appium/blob/master/test/functional/android/apidemos/notifications-specs.js#L19
    # get to the notification page
    wait { scroll_to('App').click }
    wait { scroll_to('Notification').click }
    wait { scroll_to('Status Bar').click }
    # create a notification
    wait { button(':-|').click }
    open_notifications
    # shouldn't see the elements behind shade
    wait_true { !exists { find(':-|') } }
    # should see the notification
    wait_true { text_exact 'Mood ring' }
    # return to app
    back
    # should be able to see elements from app
    wait_true { button(':-|') }

    # go back, waiting for each page to load.
    # if we go back using 3.times { back }
    # then android will flake out and discard some back events
    back
    wait { text('Status Bar') }
    back
    wait { text('Notification') }
    back
    wait { text('App') }
  end

  t 'push and pull file' do
    file = 'A Fine Day'
    path = '/data/local/tmp/remote.txt'
    wait do
      push_file path, file
      read_file = pull_file path
      read_file.must_equal file
    end
  end

  t 'pull_folder' do
    data = pull_folder '/data/local/tmp'
    data.length.must_be :>, 100
  end

  t 'ime_available_engines' do
    ime_latin = 'com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME'

    wait { find('app').click }
    wait { find('Search').click }
    wait { find('Invoke Search').click }

    imes = ime_available_engines
    imes.include?(ime_latin).must_equal true

    wait { ime_activate(ime_latin) }
    ime_active_engine.must_equal ime_latin
    ime_activated.must_equal true

    wait { ime_deactivate }
    ime_active_engine.wont_equal ime_latin

    wait { ime_activate(ime_latin) }
    ime_active_engine.must_equal ime_latin
  end
end
