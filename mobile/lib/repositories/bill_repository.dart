import 'package:afc/models/bill_model.dart';
import 'package:afc/services/bill_service.dart';

class BillRepository {
  final BillService _service;

  BillRepository({BillService? service}) : _service = service ?? BillService();

  Future<List<BillModel>> getAllBills() => _service.getAllBills();

  Future<BillModel> createBill(Map<String, dynamic> data) =>
      _service.createBill(data);

  Future<BillModel> updateBill(String id, Map<String, dynamic> data) =>
      _service.updateBill(id, data);

  Future<void> deleteBill(String id) => _service.deleteBill(id);
}
