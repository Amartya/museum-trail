import json

from django.shortcuts import render
from django.http import HttpResponse
from django.template import RequestContext
from django.shortcuts import render_to_response
from django.template import loader


from digitalrail.models import Question, iModelThematicQuestion, iModelQuestion, RailSettings, Artifact

def index(request):
    #return HttpResponse("Hello Digital Rail")
    return render_to_response('digitalrail/landingpage/index.html',context_instance=RequestContext(request))

def beaconviz(request):
    #return HttpResponse("Hello Digital Rail")
    return render_to_response('digitalrail/beaconviz/index.html',context_instance=RequestContext(request))

def bigquestion(request):
    all_questions = Question.objects.filter(rail_id=0, active=True).order_by('pub_date')

    timeout = 0
    try:
        timeout = RailSettings.objects.get(rail_id=0).timeout_seconds
    except:
        print("timeout settings for rail not found")

    if all_questions.count() > 0 :
        selected_story_id = "artifact-0-story-0"
        question_data = {}

        #return the timeout for the rail to reset to the home screen
        question_data['timeout'] = timeout

        first_question = all_questions[0]
        question_data['first_question'] = first_question.question_text
        question_data['first_additional_prompt'] = first_question.additional_prompt
        question_data['first_img_filename'] = first_question.related_img_filename

        if first_question.case_number.strip() != "":
            question_data['first_case_number'] = first_question.case_number
        else:
            question_data['first_case_number'] = False

        if first_question.selected_story_id.strip() != "":
            selected_story_id = first_question.selected_story_id.strip()

        question_data['first_selected_story_id'] = selected_story_id

        question_list = []
        for q in all_questions:
            if q.selected_story_id.strip() != "":
                selected_story_id =  q.selected_story_id.strip()

            temp_question = {'question': q.question_text, 'additional_prompt': q.additional_prompt,
                             'story_id': selected_story_id, 'img_filename': q.related_img_filename,
                             'case_number': q.case_number}
            question_list.append(temp_question)

        question_data['question_list'] = question_list

        return render(request, 'digitalrail/attractscreen/bigquestion.html', question_data)
    else:
        return HttpResponse("No data found for current request")


def imodel(request):
    thematic_question = iModelThematicQuestion.objects.filter(rail_id=0, active=True).first()
    imodel_questions = iModelQuestion.objects.filter(thematic_question=thematic_question)

    timeout = 0
    try:
        timeout = RailSettings.objects.get(rail_id=0).timeout_seconds
    except:
        print("timeout settings for rail not found")

    question_data = {}
    question_data['timeout'] = timeout

    question_list = []
    for q in imodel_questions:
        temp_question = {'question': q.imodel_question_text, 'additional_prompt': q.imodel_additional_prompt,
                         'story_id': q.selected_story_id.strip(), 'img_filename': q.related_img_filename,
                         'case_number': q.case_number, 'artifact_name': q.imodel_artifact_name}
        question_list.append(temp_question)

    question_data['question_list'] = question_list
    question_data['thematic_question'] = thematic_question.thematic_question

    return render(request, 'digitalrail/attractscreen/imodel.html', question_data)


def slidemain(request):
    artifacts = Artifact.objects.filter(rail_id=0)
    timeout = 0
    try:
        timeout = RailSettings.objects.get(rail_id=0).timeout_seconds
    except:
        print("timeout settings for rail not found")

    rail_data = {}
    rail_data['timeout'] = timeout

    artifact_list = []
    for artifact in artifacts:
        temp_artifact = {'artifact_id': artifact.artifact_id, 'artifact_name': artifact.artifact_name,
                         'label': artifact.label, 'img_filename': artifact.related_img_filename,
                         'overlay_text': artifact.artifact_overlay_text, 'interactive_type': artifact.interactive_type}
        artifact_list.append(temp_artifact)

    rail_data['artifact_list'] = artifact_list

    print(rail_data)

    return render(request, 'digitalrail/attractscreen/slidemain.html', rail_data)