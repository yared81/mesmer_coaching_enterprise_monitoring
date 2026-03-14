import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/diagnosis_provider.dart';

import 'package:mesmer_coaching_enterprise_monitoring/features/diagnosis/domain/entities/diagnosis_template_entity.dart';

class _CategoryDraft {
  String name;
  List<_QuestionDraft> questions;
  _CategoryDraft({required this.name, required this.questions});
}

class _QuestionDraft {
  String text;
  _QuestionDraft({required this.text});
}

class TemplateBuilderScreen extends ConsumerStatefulWidget {
  final DiagnosisTemplateEntity? existingProfile;

  const TemplateBuilderScreen({super.key, this.existingProfile});

  @override
  ConsumerState<TemplateBuilderScreen> createState() => _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends ConsumerState<TemplateBuilderScreen> {
  late final TextEditingController _titleController;
  final List<_CategoryDraft> _categories = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingProfile?.title ?? 'Diagnosis Template',
    );

    if (widget.existingProfile != null) {
      for (final cat in widget.existingProfile!.categories) {
        _categories.add(
          _CategoryDraft(
            name: cat.name,
            questions: cat.questions.map((q) => _QuestionDraft(text: q.text)).toList(),
          ),
        );
      }
    }
  }

  void _addCategory() {
    setState(() {
      _categories.add(_CategoryDraft(name: 'New Category', questions: []));
    });
  }

  void _addQuestion(int categoryIndex) {
    setState(() {
      _categories[categoryIndex].questions.add(_QuestionDraft(text: 'New Question'));
    });
  }

  void _removeCategory(int categoryIndex) {
    setState(() {
      _categories.removeAt(categoryIndex);
    });
  }

  void _removeQuestion(int categoryIndex, int questionIndex) {
    setState(() {
      _categories[categoryIndex].questions.removeAt(questionIndex);
    });
  }

  Future<void> _publishTemplate() async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('At least one category is required.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build the complex nest object to post to the API
      final Map<String, dynamic> payload = {
        'title': _titleController.text.trim(),
        'categories': _categories.asMap().entries.map((catEntry) {
          final catIndex = catEntry.key;
          final cat = catEntry.value;

          return {
            'name': cat.name,
            'sort_order': catIndex + 1,
            'questions': cat.questions.asMap().entries.map((qEntry) {
              final qIndex = qEntry.key;
              final q = qEntry.value;

              return {
                'text': q.text,
                'sort_order': qIndex + 1,
                // Automatically populate Yes/No/N.A as requested
                'choices': [
                  {'text': 'Yes', 'points': 2, 'sort_order': 1},
                  {'text': 'No', 'points': 0, 'sort_order': 2},
                  {'text': 'N/A', 'points': 0, 'sort_order': 3},
                ],
              };
            }).toList()
          };
        }).toList(),
      };

      final repository = ref.read(diagnosisRepositoryProvider);
      final result = await repository.createTemplate(payload);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (template) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assessment Profile Published Successfully!')));
          ref.refresh(allTemplatesProvider.future);
          context.pop();
        },
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Profile Builder', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            TextButton(
              onPressed: _publishTemplate,
              child: Text(widget.existingProfile != null ? 'UPDATE' : 'PUBLISH', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Basic Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Internal Profile Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                       Icon(Icons.info_outline, color: Color(0xFF3D5AFE), size: 16),
                       SizedBox(width: 8),
                       Expanded(child: Text('Questions created here are instantly distributed to all coaches once published. "Yes/No/N.A" choices are added automatically behind the scenes.', style: TextStyle(color: Color(0xFF3D5AFE), fontSize: 12))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Categories
          ..._categories.asMap().entries.map((catEntry) {
            final catIndex = catEntry.key;
            final category = catEntry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open_rounded, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: category.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            decoration: const InputDecoration(border: InputBorder.none, hintText: 'Category Name (e.g., Marketing)'),
                            onChanged: (val) => category.name = val,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _removeCategory(catIndex),
                          tooltip: 'Delete Category',
                        ),
                      ],
                    ),
                  ),

                  // Questions
                  if (category.questions.isEmpty)
                     const Padding(
                       padding: EdgeInsets.all(24.0),
                       child: Center(child: Text('No questions added yet.', style: TextStyle(color: Colors.grey))),
                     )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: category.questions.length,
                      separatorBuilder: (ctx, i) => Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (ctx, qIndex) {
                        final question = category.questions[qIndex];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: const Color(0xFF3D5AFE).withOpacity(0.1), shape: BoxShape.circle),
                                child: Text('${qIndex + 1}', style: const TextStyle(color: Color(0xFF3D5AFE), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: question.text,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Type your question...',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.only(top: 6),
                                  ),
                                  onChanged: (val) => question.text = val,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                                onPressed: () => _removeQuestion(catIndex, qIndex),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  // Add Question Button
                  InkWell(
                    onTap: () => _addQuestion(catIndex),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_circle_outline, color: Color(0xFF3D5AFE), size: 18),
                          SizedBox(width: 8),
                          Text('Add Question', style: TextStyle(color: Color(0xFF3D5AFE), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addCategory,
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('Add Component / Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.all(16),
              elevation: 0,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
