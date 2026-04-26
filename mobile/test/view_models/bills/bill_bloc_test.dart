import 'package:afc/models/bill_model.dart';
import 'package:afc/repositories/bill_repository.dart';
import 'package:afc/view_models/bills/bill_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBillRepository extends Mock implements BillRepository {}

void main() {
  late BillRepository repository;
  late BillBloc bloc;

  final testBills = [
    const BillModel(
      id: '1',
      name: 'Internet',
      amount: 100.0,
      dueDay: 10,
      categoryId: 'cat1',
    ),
    const BillModel(
      id: '2',
      name: 'Electricity',
      amount: 150.0,
      dueDay: 15,
      categoryId: 'cat2',
    ),
  ];

  setUp(() {
    repository = MockBillRepository();
    bloc = BillBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('BillBloc', () {
    test('initial state status is BillStatus.initial', () {
      expect(bloc.state.status, BillStatus.initial);
      expect(bloc.state.bills, isEmpty);
    });

    blocTest<BillBloc, BillState>(
      'emits [loading, success] when LoadBills succeeds',
      build: () {
        when(() => repository.getAllBills()).thenAnswer((_) async => testBills);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadBills()),
      expect: () => [
        const BillState(status: BillStatus.loading),
        BillState(status: BillStatus.success, bills: testBills),
      ],
      verify: (_) {
        verify(() => repository.getAllBills()).called(1);
      },
    );

    blocTest<BillBloc, BillState>(
      'emits [loading, failure] when LoadBills fails',
      build: () {
        when(() => repository.getAllBills()).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadBills()),
      expect: () => [
        const BillState(status: BillStatus.loading),
        const BillState(
          status: BillStatus.failure,
          errorMessage: 'Erro ao carregar contas',
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'calls createBill and reloads on CreateBill success',
      build: () {
        when(
          () => repository.createBill(any()),
        ).thenAnswer((_) async => testBills.first);
        when(() => repository.getAllBills()).thenAnswer((_) async => testBills);
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateBill({'name': 'New'})),
      expect: () => [
        const BillState(status: BillStatus.loading),
        BillState(status: BillStatus.success, bills: testBills),
      ],
      verify: (_) {
        verify(() => repository.createBill(any())).called(1);
        verify(() => repository.getAllBills()).called(1);
      },
    );

    blocTest<BillBloc, BillState>(
      'emits [failure] when CreateBill fails',
      build: () {
        when(() => repository.createBill(any())).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateBill({'name': 'New'})),
      expect: () => [
        const BillState(
          status: BillStatus.failure,
          errorMessage: 'Erro ao criar conta',
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'calls updateBill and reloads on UpdateBill success',
      build: () {
        when(
          () => repository.updateBill(any(), any()),
        ).thenAnswer((_) async => testBills.first);
        when(() => repository.getAllBills()).thenAnswer((_) async => testBills);
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateBill('1', {'name': 'Updated'})),
      expect: () => [
        const BillState(status: BillStatus.loading),
        BillState(status: BillStatus.success, bills: testBills),
      ],
      verify: (_) {
        verify(() => repository.updateBill('1', any())).called(1);
        verify(() => repository.getAllBills()).called(1);
      },
    );

    blocTest<BillBloc, BillState>(
      'emits [failure] when UpdateBill fails',
      build: () {
        when(
          () => repository.updateBill(any(), any()),
        ).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateBill('1', {'name': 'Updated'})),
      expect: () => [
        const BillState(
          status: BillStatus.failure,
          errorMessage: 'Erro ao atualizar conta',
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'calls deleteBill and reloads on DeleteBill success',
      build: () {
        when(() => repository.deleteBill(any())).thenAnswer((_) async {});
        when(() => repository.getAllBills()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteBill('1')),
      expect: () => [
        const BillState(status: BillStatus.loading),
        const BillState(status: BillStatus.success, bills: []),
      ],
      verify: (_) {
        verify(() => repository.deleteBill('1')).called(1);
        verify(() => repository.getAllBills()).called(1);
      },
    );

    blocTest<BillBloc, BillState>(
      'emits [failure] when DeleteBill fails',
      build: () {
        when(() => repository.deleteBill(any())).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteBill('1')),
      expect: () => [
        const BillState(
          status: BillStatus.failure,
          errorMessage: 'Erro ao excluir conta',
        ),
      ],
    );
  });
}
