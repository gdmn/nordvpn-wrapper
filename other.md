# Other things...

List top NL servers with usage percent:

    wget --quiet --header 'cache-control: no-cache' -O - 'https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations&filters={%22country_id%22:153}' | jq -r '.[] | [ .hostname, .load ] | join(", ") | . + "%"'

