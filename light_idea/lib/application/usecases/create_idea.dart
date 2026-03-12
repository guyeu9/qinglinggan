import '../../core/constants/app_constants.dart';
import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';

class CreateIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;

  CreateIdeaUseCase(this._ideaRepository, this._logger);

  Future<Result<IdeaEntity>> execute(String content) async {
    if (content.trim().isEmpty) {
      _logger.warning('创建灵感失败: 内容为空');
      return Result.error('内容不能为空');
    }

    if (content.length > AppConstants.maxContentLength) {
      _logger.warning(
          '创建灵感失败: 内容超长 (${content.length} > ${AppConstants.maxContentLength})');
      return Result.error('内容长度不能超过${AppConstants.maxContentLength}字符');
    }

    try {
      final now = DateTime.now();
      final idea = IdeaEntity(
        id: 0,
        content: content.trim(),
        createdAt: now,
        updatedAt: now,
        aiStatus: AIStatus.pending,
      );

      final savedIdea = await _ideaRepository.save(idea);

      _logger.info('灵感创建成功: id=${savedIdea.id}');

      return Result.success(savedIdea);
    } catch (e, st) {
      _logger.error('创建灵感失败', e, st);
      return Result.error('保存失败: $e', e);
    }
  }
}
