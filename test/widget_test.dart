import 'package:flutter_test/flutter_test.dart';
import 'package:vaja001_rps/main.dart';
import 'package:vaja001_rps/models/borrow_request.dart';
import 'package:vaja001_rps/models/user.dart';
import 'package:vaja001_rps/services/data_service.dart';

void main() {
  testWidgets('Full local ticket approval, theme toggle & role hierarchy test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RpsRentalApp());
    expect(find.text('RPS Rental Hub'), findsOneWidget);

    final data = DataService.instance;

    // 1. Preveri preklop med Dark in Light temo
    expect(data.isDarkMode, isTrue);
    data.toggleThemeMode();
    expect(data.isDarkMode, isFalse);

    // 2. Ustvari novega lokalnega uporabnika v testiranju
    final testCustomer = data.registerUser(
      name: 'Testni Uporabnik',
      email: 'test@rps.local',
      password: '123',
      role: UserRole.customer,
      autoSignIn: true,
    );

    // 3. Uporabnik odda nov ticket s promo kodo RPS10 (-10%)
    final firstItem = data.items.first;
    final initialStock = firstItem.availableStock;
    final ticket = data.createBorrowRequest(
      itemId: firstItem.id,
      quantity: 1,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 2)),
      promoCode: 'RPS10',
    );

    expect(ticket.status, BorrowStatus.pending);
    expect(ticket.discountPercent, 10.0);

    // 4. Preklopi na Employee račun in odobri ticket
    final employee =
        data.users.firstWhere((u) => u.role == UserRole.employee);
    data.quickSignIn(employee);
    data.approveBorrowRequest(ticket.id);

    // 5. Preveri, da je ticket odobren, zaloga zmanjšana in račun izdan
    final updatedTicket =
        data.borrowRequests.firstWhere((t) => t.id == ticket.id);
    expect(updatedTicket.status, BorrowStatus.approved);
    expect(data.getItemById(firstItem.id)!.availableStock, initialStock - 1);
    expect(
      data.getBillsForUser(testCustomer.id).any(
            (b) => b.borrowRequestId == ticket.id,
          ),
      isTrue,
    );
  });
}