ui:
  header: "${customer_name} - ${application_1} connectivity dashboard"
  title: "${customer_name} - ${application_1} connectivity dashboard"
endpoints:
  - name : ${application_2}
    url: "icmp://${application_2_ip}"
    interval: 10s
    group: Applications
    conditions:
      - "[CONNECTED] == true"