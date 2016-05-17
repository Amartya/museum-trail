import json

from django.shortcuts import render
from django.http import HttpResponse
from django.template import RequestContext
from django.shortcuts import render_to_response
from django.template import loader


from digitalrail.models import Question

def index(request):
    #return HttpResponse("Hello Digital Rail")
    return render_to_response('digitalrail/landingpage/index.html',context_instance=RequestContext(request))


def bigquestion(request):
    first_question = Question.objects.filter(rail_id=0, active=True).order_by('-pub_date')[0]
    question_data = {}
    question_data['question'] = first_question.question_text
    question_data['additional_prompt'] = first_question.additional_prompt

    return render(request, 'digitalrail/attractscreen/bigquestion.html', question_data)

def fox(request):
    first_question = Question.objects.filter(rail_id=1, active=True).order_by('-pub_date')[0]
    question_data = {}
    question_data['question'] = first_question.question_text
    question_data['additional_prompt'] = first_question.additional_prompt

    print('FOX')
    return render(request, 'digitalrail/fox/fox.html', question_data)