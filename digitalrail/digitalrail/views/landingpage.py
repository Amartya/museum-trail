import json
import sys
from datetime import datetime

from django.shortcuts import render
from django.http import HttpResponse
from django.template import RequestContext
from django.shortcuts import render_to_response
from django.template import loader
from django.views.decorators.csrf import csrf_exempt

from digitalrail.models import Question, iModelThematicQuestion, iModelQuestion, RailSettings, Artifact, ArtifactQA, \
    WatchInteractivity, SavedData

def index(request):
    #return HttpResponse("Hello Digital Rail")
    return render_to_response('digitalrail/landingpage/index.html',context_instance=RequestContext(request))

def beaconviz(request):
    #return HttpResponse("Hello Digital Rail")
    return render_to_response('digitalrail/beaconviz/index.html',context_instance=RequestContext(request))

def experiments(request):
    #return HttpResponse("Hello Digital Rail")
    return render_to_response('digitalrail/experiments/index.html',context_instance=RequestContext(request))

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

    artifact_detail_list = []
    for artifact in artifacts:
        artifact_qa = ArtifactQA.objects.get(artifact = artifact)
        temp_artifact_qa = {'artifact_id': artifact.artifact_id, 'artifact_name': artifact_qa.artifact_name,
                         'label': artifact_qa.artifact_label, 'artifact_dynasty_age': artifact_qa.artifact_dynasty_age,
                         'questions': artifact_qa.artifact_questions, 'answers': artifact_qa.artifact_answers}
        artifact_detail_list.append(temp_artifact_qa)

    rail_data['artifact_detail_list'] = artifact_detail_list

    return render(request, 'digitalrail/attractscreen/slidemain.html', rail_data)

@csrf_exempt
def setwatchstatus(request):
    if request.method == "POST":
        request_body = request.body
        try:
            data = json.loads(request_body)
            if data['name'] == "ios":
                setscreenstatus()
                return HttpResponse(json.dumps({'watchstatus': True}), content_type='application/javascript')
        except:
            if request.POST.get('name') == "rail":
                setscreenstatus()
                return HttpResponse(json.dumps({'watchstatus': True}), content_type='application/javascript')
            else:
                print("error parsing request data to set watch status")

def setscreenstatus():
    watchstatus = WatchInteractivity.objects.get(id=1)
    watchstatus.show_watch_area = not watchstatus.show_watch_area
    watchstatus.save()

    # resetting the selected story id to the default
    if (not watchstatus.show_watch_area):
        watchstatus.selected_story_id = -1
        watchstatus.show_story = False
        watchstatus.save()

@csrf_exempt
def getwatchstatus(request):
    if request.method == "POST":
        if request.POST.get('name') == "rail":
            watchstatus = WatchInteractivity.objects.get(id=1)
            watchdata = {'watchstatus': watchstatus.show_watch_area}
            return HttpResponse(json.dumps(watchdata), content_type='application/javascript')


@csrf_exempt
def setwatchstory(request):
    if request.method == "POST":
        request_body = request.body
        try:
            data = json.loads(request_body)

            if data['name'] == "watch":
                watchstatus = WatchInteractivity.objects.get(id=1)
                watchstatus.selected_story_id = data['promptId']
                watchstatus.save()
                return HttpResponse(json.dumps({'watchstoryset': True}), content_type='application/javascript')
        except Exception as e:
            if hasattr(e, 'message'):
                print >> sys.stderr, prettyprint(e.message)
            else:
                print >> sys.stderr, prettyprint(e)
    elif request.method == "GET":
        print >> sys.stderr, prettyprint(request.body)
        return HttpResponse(json.dumps({'watchstoryset': False}), content_type='application/javascript')


@csrf_exempt
def getwatchstory(request):
    if request.method == "POST":
        if request.POST.get('name') == "rail":
            watchstatus = WatchInteractivity.objects.get(id=1)
            watchdata = {'watchstory': watchstatus.selected_story_id}
            return HttpResponse(json.dumps(watchdata), content_type='application/javascript')

@csrf_exempt
def setdisplaystory(request):
    if request.method == "POST":
        request_body = request.body
        try:
            data = json.loads(request_body)

            if data['name'] == "watch":
                setstoryhelper()
                return HttpResponse(json.dumps({'watchstoryset': True}), content_type='application/javascript')
        except:
            if request.POST.get('name') == "rail":
                setstoryhelper()
                return HttpResponse(json.dumps({'watchstoryset': True}), content_type='application/javascript')
            print("error parsing request data to set display story")

def setstoryhelper():
    watchstatus = WatchInteractivity.objects.get(id=1)
    watchstatus.show_story = not watchstatus.show_story
    watchstatus.save()

@csrf_exempt
def getdisplaystory(request):
    if request.method == "POST":
        if request.POST.get('name') == "rail":
            watchstatus = WatchInteractivity.objects.get(id=1)
            watchdata = {'displaystory': watchstatus.show_story, 'storyId': watchstatus.selected_story_id}

            return HttpResponse(json.dumps(watchdata), content_type='application/javascript')
        else:
            request_body = request.body

            try:
                data = json.loads(request_body)
                if data['name'] == "ios":
                    watchstatus = WatchInteractivity.objects.get(id=1)
                    watchdata = {'displaystory': watchstatus.show_story, 'storyId': watchstatus.selected_story_id}

                    return HttpResponse(json.dumps(watchdata), content_type='application/javascript')
            except:
                return HttpResponse(json.dumps({'displaystory': "could not set"}), content_type='application/javascript')


@csrf_exempt
def savedata(request):
    if request.method == "POST":
        if request.POST.get('name') == "rail":
            saved_story_id = request.POST.get('storyId')
            data = SavedData(selected_story_id = saved_story_id, saved_timestamp = datetime.now())
            data.save()

            savedata = {'saveddata': True}
            return HttpResponse(json.dumps(savedata), content_type='application/javascript')

@csrf_exempt
def getsavedata(request):
    if request.method == "POST":
        request_body = request.body
        try:
            data = json.loads(request_body)
            if data['name'] == "ios":
                save_data = SavedData.objects.order_by('-id').first()
                response_data = {"id": save_data.id, "success": True}
                prettyprint(response_data)
                return HttpResponse(json.dumps(response_data), content_type='application/javascript')
        except:
            return HttpResponse(json.dumps({'success': "false"}), content_type='application/javascript')


def prettyprint(print_str):
    print '***************************************************'
    print(print_str)
    print '***************************************************'