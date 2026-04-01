{{- $fullName := include "chart.fullname" . -}}
{{- $labels := include "chart.labels" . -}}
{{- $selectorLabels := include "chart.selectorLabels" . -}}
{{- $shareVolume := .Values.shareVolume -}}
{{- $persistenceValues := .Values.persistence.enabled -}}
{{- $persistencemountPath := .Values.persistence.mountPath -}}

{{- if eq .Values.kind "StatefulSet" }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $fullName }}
  labels:
    {{- $labels | nindent 4 }}
    {{- with .Values.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    reloader.stakater.com/auto: "true"
spec:
  replicas: {{ .Values.replicaCount }}
  serviceName: {{ $fullName }}
  podManagementPolicy: {{ .Values.podManagementPolicy }}
  revisionHistoryLimit: {{ .Values.revisionHistoryLimit | default 10 }}
  {{- with .Values.updateStrategy }}
  updateStrategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.persistence.claimRetentionPolicy }}
  persistentVolumeClaimRetentionPolicy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  ordinals:
    start: {{ .Values.ordinalsStart | default 0 }}
  {{- if gt (int .Values.minReadySeconds) 0 }}
  minReadySeconds: {{ .Values.minReadySeconds }}
  {{- end }}
  selector:
    matchLabels:
      {{- $selectorLabels | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- $selectorLabels | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "chart.serviceAccountName" . }}
      automountServiceAccountToken: {{ .Values.serviceAccount.automount | default true }}
      enableServiceLinks: {{ .Values.enableServiceLinks | default true }}
      {{- with .Values.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds: {{ . }}
      {{- end }}
      dnsPolicy: {{ .Values.dnsPolicy | default "ClusterFirst" }}
      {{- with .Values.dnsConfig }}
      dnsConfig:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.runtimeClassName }}
      runtimeClassName: {{ . }}
      {{- end }}
      {{- with .Values.priorityClassName }}
      priorityClassName: {{ . }}
      {{- end }}
      {{- with .Values.schedulerName }}
      schedulerName: {{ . }}
      {{- end }}
      {{- with .Values.readinessGates }}
      readinessGates:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      shareProcessNamespace: {{ .Values.shareProcessNamespace }}
      {{- if ( .Values.initcontainers | default false ) }}
      initContainers:
        {{- range $init := .Values.initcontainers }}
        - name: {{ $init.name }}
          {{- with $init.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          image: "{{ $init.image.repository }}:{{ $init.image.tag | default "latest" }}"
          imagePullPolicy: {{ $init.image.pullPolicy | default "IfNotPresent" }}
          {{- with $init.workingDir }}
          workingDir: {{ . }}
          {{- end }}
          {{- with $init.image.command }}
          command:
          {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $init.image.args }}
          args:
          {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $init.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if or $init.envFrom $init.configEnv }}
          envFrom:
          {{- if $init.envFrom }}
            {{- toYaml $init.envFrom | nindent 12 }}
          {{- end }}
          {{- if $init.configEnv }}
            - configMapRef:
                name: {{ $fullName }}-config-env
          {{- end }}
          {{- end }}
          {{- with $init.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $init.restartPolicy }}
          restartPolicy: {{ . }}
          {{- end }}
          {{- with $init.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $init.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $init.startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          terminationMessagePolicy: {{ $init.terminationMessagePolicy | default "File" }}
          terminationMessagePath: {{ $init.terminationMessagePath | default "/dev/termination-log" }}
          {{- if $init.stdin }}
          stdin: true
          {{- end }}
          {{- if $init.tty }}
          tty: true
          {{- end }}
          volumeMounts:
            - name: sharevolume
              mountPath: {{ $shareVolume }}
          {{- with $init.volumeMounts }}
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if $persistenceValues }}
            - name: {{ $fullName }}
              mountPath: {{ $persistencemountPath }}
          {{- end }}
        {{- end }}
      {{- end }}
      containers:
        {{- range $containers := .Values.containers }}
        - name: {{ $containers.name }}
          {{- with $containers.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          image: "{{ $containers.image.repository }}:{{ $containers.image.tag | default "latest" }}"
          imagePullPolicy: {{ $containers.image.pullPolicy | default "IfNotPresent" }}
          {{- with $containers.workingDir }}
          workingDir: {{ . }}
          {{- end }}
          {{- with $containers.image.command }}
          command:
          {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $containers.image.args }}
          args:
          {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $containers.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if or $containers.envFrom $containers.configEnv }}
          envFrom:
          {{- if $containers.envFrom }}
            {{- toYaml $containers.envFrom | nindent 12 }}
          {{- end }}
          {{- if $containers.configEnv }}
            - configMapRef:
                name: {{ $fullName }}-config-env
          {{- end }}
          {{- end }}
          {{- with $containers.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $containers.resizePolicy }}
          resizePolicy:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if and $containers.service ( $containers.service.enabled | default false ) }}
          ports:
            {{- range $port := $containers.service.ports }}
            - name: {{ $port.name }}
              containerPort: {{ $port.targetPort }}
              protocol: {{ $port.protocol }}
            {{- end }}
          {{- end }}
          {{- with $containers.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $containers.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $containers.startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $containers.lifecycle }}
          lifecycle:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          terminationMessagePolicy: {{ $containers.terminationMessagePolicy | default "File" }}
          terminationMessagePath: {{ $containers.terminationMessagePath | default "/dev/termination-log" }}
          {{- if $containers.stdin }}
          stdin: true
          {{- end }}
          {{- if $containers.tty }}
          tty: true
          {{- end }}
          volumeMounts:
            - name: sharevolume
              mountPath: {{ $shareVolume }}
          {{- with $containers.volumeMounts }}
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if $persistenceValues }}
            - name: {{ $fullName }}
              mountPath: {{ $persistencemountPath }}
          {{- end }}
        {{- end }}
      volumes:
        - name: sharevolume
          emptyDir: {}
      {{- with .Values.volumes }}
      {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if .Values.configEnv.enabled }}
        - name: config-env
          configMap:
            name:  {{ $fullName }}-config-env
      {{- end }}
      {{- if .Values.configMap.enabled }}
        - name: config-map
          configMap:
            name:  {{ $fullName }}-config-file
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.hostAliases }}
      hostAliases:
        {{- toYaml . | nindent 8 }}
      {{- end }}
  {{- if or .Values.persistence.enabled }}
  volumeClaimTemplates:
    {{- if or .Values.persistence.enabled }}
    - metadata:
        name: {{ $fullName }}
      spec:
        accessModes: [{{ .Values.persistence.accessMode }}]
        resources:
          requests:
            storage: {{ .Values.persistence.size }}
        storageClassName: {{ .Values.persistence.storageClass }}
    {{- end }}
  {{- end }}
{{- end }}