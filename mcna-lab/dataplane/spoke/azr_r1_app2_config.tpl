ui:
  header: "${customer_name} - ${application_2} connectivity dashboard"
  title: "${customer_name} - ${application_2} connectivity dashboard"
endpoints:
  - name : ${customer_website}
    method: GET
    url: "https://${customer_website}"
    interval: 5s
    group: Applications
    conditions:
      - "[STATUS] == 403"
  - name : github.com/AviatrixSystems
    method: GET
    url: "https://github.com/AviatrixSystems"
    interval: 5s
    group: Applications
    conditions:
      - "[STATUS] == 200"
  - name : github.com
    method: GET
    url: "https://github.com"
    interval: 5s
    group: Applications
    conditions:
      - "[STATUS] == 200"