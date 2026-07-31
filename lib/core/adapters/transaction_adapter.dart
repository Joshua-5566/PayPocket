import 'package:hive/hive.dart';
import '../../features/transaction/models/transaction.dart';
import '../../features/transaction/models/category.dart'; // don't forget this!

class TransactionAdapter extends TypeAdapter<ExpenseTransaction> {
  @override
  final int typeId = 0;

  @override
  ExpenseTransaction read(BinaryReader reader) {
    return ExpenseTransaction(
      id: reader.readString(),
      title: reader.readString(),
      amount: reader.readDouble(),
      type: TransactionType.values[reader.readInt()],
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      icon: reader.readString(),
      category: TransactionCategory.values[reader.readInt()], // <-- ADD THIS
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseTransaction obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.type.index);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.icon);
    writer.writeInt(obj.category.index); // this was already correct
  }
}
