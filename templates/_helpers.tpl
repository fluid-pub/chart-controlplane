{{- define "controlplane.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "controlplane.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "controlplane.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end }}

{{- define "controlplane.labels" -}}
helm.sh/chart: {{ include "controlplane.chart" . }}
{{ include "controlplane.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "controlplane.selectorLabels" -}}
app.kubernetes.io/name: {{ include "controlplane.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Agent WebSocket affinity: dedicated HTTPRoute + BackendTrafficPolicy (consistent hash).
Enabled when gatewayApi.enabled and replicaCount > 1 unless gatewayApi.agentAffinity.enabled is set explicitly.
*/}}
{{- define "controlplane.agentAffinity.enabled" -}}
{{- if .Values.gatewayApi.enabled -}}
{{- if kindIs "bool" .Values.gatewayApi.agentAffinity.enabled -}}
{{- if .Values.gatewayApi.agentAffinity.enabled -}}true{{- end -}}
{{- else if gt (int .Values.replicaCount) 1 -}}true{{- end -}}
{{- end -}}
{{- end -}}
