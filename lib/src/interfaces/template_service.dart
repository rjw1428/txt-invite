
import 'package:txt_invite/src/models/invitation.dart';

abstract class TemplateService {
  Future<List<Invitation>> getAllTemplates();
}
