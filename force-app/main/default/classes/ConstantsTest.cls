/* Class:       ConstantsTest
** Created by:  OpFocus (Jason Curry) on 2021-06-21
** Description: Test Class for Constants file.
** Just need to test the constructor for code coverage.
*/

@IsTest(IsParallel=true)
private class ConstantsTest {

    @IsTest
    static void testConstructor() {
        Test.startTest();
        Constants c = new Constants();
        System.assert(true, 'Easy peasy lemon squeezy');
        Test.stopTest();
    }
}