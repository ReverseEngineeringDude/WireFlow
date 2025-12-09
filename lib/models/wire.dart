import 'enums.dart';
import 'pin.dart';

class Wire {
  final Pin from;
  final Pin to;
  LogicState state = LogicState.low;
  bool isInvalid = false;

  Wire(this.from, this.to) {
    from.connections.add(this);
    to.connections.add(this);
  }

  void dispose() {
    from.connections.remove(this);
    to.connections.remove(this);
  }
}
