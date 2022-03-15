require 'selenium-webdriver'
require 'webdrivers'
require 'date'

class Wakasu
  def initialize(addresses, password)
    @addresses = addresses
    @password = password
  end

  def muitithreds_execute
    threds = []
    @addresses.each do |address|
      threds << Thread.new(address, @password) do |address, password|
        Selenium::WebDriver::Chrome.driver_path = '/usr/local/bin/chromedriver'
        driver = Selenium::WebDriver.for :chrome
        # 要素発見までの待ち時間
        driver.manage.timeouts.implicit_wait = 1
        wait = Selenium::WebDriver::Wait.new(:timeout => 10)
          login(address, password, driver)
          reserve(driver)
        end
    end

    threds.join
  end

  private

  def login(address, password, driver)
    driver.get("https://www.jgo-os.com/reserve/come.cgi?courseid=13103&amp;userkindid=003")
    element_id   = driver.find_element(:name, 'login_email')
    element_pass = driver.find_element(:name, 'login_pswd')
    element_id.send_keys address
    element_pass.send_keys password
    driver.find_element(:xpath, '//*[@id="header"]/header/form/div[2]/div/div[2]/p').click
  end

  def reserve(driver)
    target_date = Date.today.next_month - 1
    # year, month, day, plan, play, redflg
    driver.execute_script("reserve(#{target_date.year}, #{target_date.month}, #{target_date.day}, 54, 4, 1)")
    # driver.execute_script("reserve(2022, 1, 30, 54, 4, 1)")
    # 枠が出るまではこれを繰り返す必要がある
    while driver.find_elements(:class, 'selectmenu2').empty?
      driver.navigate.back
      driver.execute_script("reserve(#{target_date.year}, #{target_date.month}, #{target_date.day}, 54, 4, 1)")
      # driver.execute_script("reserve(2022, 1, 30, 54, 4, 1)")
    end
    # 予約人数の決定
    element = driver.find_element(:class, 'selectmenu2')
    select = Selenium::WebDriver::Support::Select.new(element)
    select.select_by(:value, '4')
    reserve_botton_xpath = "//*[@id='contents']/article/form/div[2]/p/a[2]/img"
    # 10時予約受付開始
    while DateTime.now < DateTime.parse("#{Date.today.year}-#{Date.today.month}-#{Date.today.day} 10:00:00 +0900")
      sleep 0.001
    end
    driver.find_element(:xpath, reserve_botton_xpath).click
    driver.execute_script("go_thanks(window)")
  end

  def has_error?
    driver.find_element(:class, 'error')
  end
end

# 下記のメールアドレスとパスワードを使っているものに更新する。
wakasu = Wakasu.new(
  [
    'test@example.com',
    'test2@example.com'
  ],
  'password'
)
wakasu.muitithreds_execute

sleep 1000