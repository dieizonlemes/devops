variable "nome_cluster" {
  description = "Nome do cluster kind (o contexto do kubectl será kind-<nome>)"
  type        = string
  default     = "devops-lab"
}

variable "habilitar_monitoramento" {
  description = "Instala Prometheus, Alertmanager e Grafana no cluster (Módulo 6)"
  type        = bool
  default     = false
}
