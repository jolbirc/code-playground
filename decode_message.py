import requests
from bs4 import BeautifulSoup


# Takes doc link, parse data, print grid of char in fix width font
def parse_and_decode(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")
    table = soup.find("table")
    rows = table.find_all("tr")

    grid = {}

    for row in rows[1:]:
        cols = row.find_all("td")
        x = int(cols[0].text.strip())
        char = cols[1].text.strip()
        y = int(cols[2].text.strip())
        grid[(x, y)] = char

    max_x = max(x for x, y in grid)
    max_y = max(y for x, y in grid)

    for y in range(max_y, -1, -1):
        for x in range(max_x + 1):
            print(grid.get((x, y), " "), end="")
        print()


parse_and_decode(
    "https://docs.google.com/document/d/e/2PACX-1vSvM5gDlNvt7npYHhp_XfsJvuntUhq184By5xO_pA4b_gCWeXb6dM6ZxwN8rE6S4ghUsCj2VKR21oEP/pub"
)
