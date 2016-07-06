from django.contrib import admin
from .models import Question, iModelThematicQuestion, iModelQuestion

def duplicate_question(modeladmin, request, queryset):
    for question in queryset:
        question.pk = None
        question.question_text = ""
        question.save()
duplicate_question.short_description = "Duplicate selected question"

def duplicate_imodel_thematic_question(modeladmin, request, queryset):
    for thematic_question in queryset:
        thematic_question.pk = None
        thematic_question.thematic_question = ""
        thematic_question.save()
duplicate_imodel_thematic_question.short_description = "Duplicate selected question"

def duplicate_imodel_question(modeladmin, request, queryset):
    for imodel in queryset:
        imodel.pk = None
        imodel.imodel_question_text = ""
        imodel.save()

duplicate_imodel_question.short_description = "Duplicate selected question"

class bigQuestionAdmin(admin.ModelAdmin):
    list_display = ['id', 'rail_id', 'question_text', 'case_number', 'pub_date', 'active']
    ordering = ['id']
    actions = [duplicate_question]

class thematicQuestionAdmin(admin.ModelAdmin):
    list_display = ['id', 'rail_id', 'thematic_question', 'pub_date', 'active']
    ordering = ['id']
    actions = [duplicate_imodel_question]

class iModelQuestionAdmin(admin.ModelAdmin):
    list_display = ['id', 'imodel_artifact_name', 'imodel_question_text', 'case_number', 'pub_date']
    ordering = ['id']
    actions = [duplicate_imodel_question]

admin.site.register(Question, bigQuestionAdmin)
admin.site.register(iModelThematicQuestion, thematicQuestionAdmin)
admin.site.register(iModelQuestion, iModelQuestionAdmin)
