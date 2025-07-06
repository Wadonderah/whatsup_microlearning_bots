import 'package:flutter/material.dart';
import '../../../core/models/prompt_template.dart';
import '../../../core/services/prompt_template_service.dart';

class PromptTemplateSelector extends StatefulWidget {
  final Function(PromptTemplate, Map<String, String>) onTemplateSelected;

  const PromptTemplateSelector({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  State<PromptTemplateSelector> createState() => _PromptTemplateSelectorState();
}

class _PromptTemplateSelectorState extends State<PromptTemplateSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PromptTemplateService _templateService = PromptTemplateService.instance;
  final TextEditingController _searchController = TextEditingController();
  
  List<PromptTemplate> _filteredTemplates = [];
  Map<PromptCategory, List<PromptTemplate>> _groupedTemplates = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _tabController = TabController(
      length: PromptCategory.values.length + 1, // +1 for "All" tab
      vsync: this,
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadTemplates() {
    _groupedTemplates = _templateService.getTemplatesGroupedByCategory();
    _filteredTemplates = _templateService.getAllTemplates();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredTemplates = _templateService.searchTemplates(query);
      } else {
        _filteredTemplates = _templateService.getAllTemplates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),
        
        // Category tabs (hidden when searching)
        if (!_isSearching) _buildCategoryTabs(),
        
        // Template list
        Expanded(
          child: _isSearching 
              ? _buildSearchResults()
              : _buildCategoryContent(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search templates...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: [
          const Tab(text: 'All'),
          ...PromptCategory.values.map((category) => Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.icon),
                const SizedBox(width: 4),
                Text(category.displayName),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredTemplates.isEmpty) {
      return _buildEmptyState('No templates found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(_filteredTemplates[index]);
      },
    );
  }

  Widget _buildCategoryContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // All templates
        _buildTemplateList(_templateService.getAllTemplates()),
        
        // Category-specific templates
        ...PromptCategory.values.map((category) {
          final templates = _groupedTemplates[category] ?? [];
          return _buildTemplateList(templates);
        }),
      ],
    );
  }

  Widget _buildTemplateList(List<PromptTemplate> templates) {
    if (templates.isEmpty) {
      return _buildEmptyState('No templates in this category');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(templates[index]);
      },
    );
  }

  Widget _buildTemplateCard(PromptTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTemplateDialog(template),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    template.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      template.category.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                template.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
              if (template.placeholders.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: template.placeholders.map((placeholder) {
                    return Chip(
                      label: Text(
                        placeholder,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Colors.grey[200],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showTemplateDialog(PromptTemplate template) {
    showDialog(
      context: context,
      builder: (context) => TemplateInputDialog(
        template: template,
        onSubmit: (values) {
          widget.onTemplateSelected(template, values);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class TemplateInputDialog extends StatefulWidget {
  final PromptTemplate template;
  final Function(Map<String, String>) onSubmit;

  const TemplateInputDialog({
    super.key,
    required this.template,
    required this.onSubmit,
  });

  @override
  State<TemplateInputDialog> createState() => _TemplateInputDialogState();
}

class _TemplateInputDialogState extends State<TemplateInputDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _values = {};

  @override
  void initState() {
    super.initState();
    for (final placeholder in widget.template.placeholders) {
      _controllers[placeholder] = TextEditingController();
      _controllers[placeholder]!.addListener(() {
        _values[placeholder] = _controllers[placeholder]!.text;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(widget.template.icon),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.template.name)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.template.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ...widget.template.placeholders.map((placeholder) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[placeholder],
                  decoration: InputDecoration(
                    labelText: placeholder.replaceAll('_', ' ').toUpperCase(),
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.template.hasAllRequiredValues(_values)
              ? () => widget.onSubmit(_values)
              : null,
          child: const Text('Use Template'),
        ),
      ],
    );
  }
}
