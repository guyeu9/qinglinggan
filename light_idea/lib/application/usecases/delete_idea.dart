import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/idea_repository.dart';
import '../../domain/repositories/association_repository.dart';
import '../../domain/repositories/ai_analysis_repository.dart';
import '../../domain/repositories/ai_task_repository.dart';

class DeleteIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AssociationRepository _associationRepository;
  final AIAnalysisRepository _analysisRepository;
  final AITaskRepository _taskRepository;
  final AppLogger _logger;

  DeleteIdeaUseCase(
    this._ideaRepository,
    this._associationRepository,
    this._analysisRepository,
    this._taskRepository,
    this._logger,
  );

  Future<Result<void>> execute(int id, {bool permanent = false}) async {
    try {
      final existingIdea = await _ideaRepository.getById(id);
      if (existingIdea == null) {
        _logger.warning('删除灵感失败: 灵感不存在 id=$id');
        return Result.error('灵感不存在');
      }

      _logger.info('开始清理灵感关联数据: id=$id');
      
      await _associationRepository.deleteByIdeaId(id);
      _logger.debug('已删除关联数据: ideaId=$id');
      
      await _analysisRepository.deleteByIdeaId(id);
      _logger.debug('已删除AI分析结果: ideaId=$id');
      
      await _taskRepository.deleteByIdeaId(id);
      _logger.debug('已删除AI任务: ideaId=$id');

      if (permanent) {
        await _ideaRepository.permanentDelete(id);
        _logger.info('灵感永久删除成功: id=$id');
      } else {
        await _ideaRepository.softDelete(id);
        _logger.info('灵感软删除成功: id=$id');
      }

      return Result.success(null);
    } catch (e, st) {
      _logger.error('删除灵感失败: id=$id', e, st);
      return Result.error('删除失败: $e', e);
    }
  }
}
