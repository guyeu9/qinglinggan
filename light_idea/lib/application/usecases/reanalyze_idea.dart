import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/ai_task.dart';
import '../task_queue/ai_task_queue.dart';

class ReanalyzeIdeaUseCase {
  final AITaskQueue _taskQueue;
  final AppLogger _logger;

  ReanalyzeIdeaUseCase(this._taskQueue, this._logger);

  Future<Result<bool>> execute(int ideaId) async {
    if (ideaId <= 0) {
      _logger.warning('重新分析失败: 无效的灵感ID');
      return Result.error('无效的灵感ID');
    }

    try {
      _logger.info('触发重新分析: ideaId=$ideaId');

      final result = await _taskQueue.enqueue(
        ideaId,
        taskType: TaskType.fullAnalysis,
        force: true,
      );

      if (result.wasEnqueued) {
        _logger.info('重新分析任务已入队: ideaId=$ideaId');
        return Result.success(true);
      } else {
        _logger.warning('重新分析任务跳过: ideaId=$ideaId, reason=${result.reason}');
        return Result.success(false);
      }
    } catch (e, st) {
      _logger.error('重新分析失败', e, st);
      return Result.error('重新分析失败: $e', e);
    }
  }
}
