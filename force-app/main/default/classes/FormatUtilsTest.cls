@IsTest
private class FormatUtilsTest {
  @IsTest
  static void phoneFormats() {
    Assert.areEqual('(919) 555-0123', FormatUtils.usPhone('9195550123'));
    Assert.areEqual('(919) 555-0123', FormatUtils.usPhone('(919) 555 0123'));
    Assert.areEqual('(919) 555-0123', FormatUtils.usPhone('+1-919-555-0123'));
    Assert.areEqual('555-0123', FormatUtils.usPhone('555-0123'));
    Assert.areEqual(
      '+44 20 7946 0958',
      FormatUtils.usPhone('+44 20 7946 0958')
    );
    Assert.isNull(FormatUtils.usPhone(null));
  }

  @IsTest
  static void zipFormats() {
    Assert.areEqual('27601', FormatUtils.usZip(' 27601 '));
    Assert.areEqual('27601-1234', FormatUtils.usZip('27601 1234'));
    Assert.areEqual('SW1A 1AA', FormatUtils.usZip('SW1A 1AA '));
    Assert.areEqual('', FormatUtils.usZip(''));
  }
}
