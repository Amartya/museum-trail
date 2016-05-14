from django.http import HttpResponse
from django.template import RequestContext
from django.shortcuts import render_to_response

def index(request):
    #return HttpResponse("Hello Digital Rail")
    return render_to_response('digitalrail/landingpage/index.html',RequestContext(request))

def bigquestion(request):
    #return HttpResponse("Hello Digital Rail")
    return render_to_response('digitalrail/attractscreen/bigquestion.html',RequestContext(request))