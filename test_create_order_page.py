 
import os
import re
from pathlib import Path

import pytest
from playwright.sync_api import Page, expect

PAGE_PATH = Path(os.environ.get("PAGE_PATH", Path(__file__).parent / "CreateOrder.html"))
ORIGIN = "http://test.local"

CLIENTS = [
    {"ClientId": 1, "ClientName": "Acme Ltd"},
    {"ClientId": 2, "ClientName": "Beta Corp"},
]
GOODS = {
    "1": [
        {"GoodId": 10, "GoodName": "Chair", "Price": 49.9},
        {"GoodId": 20, "GoodName": "Table", "Price": 120},
    ],
    "2": [
        {"GoodId": 30, "GoodName": "Lamp", "Price": 15},
    ],
}


@pytest.fixture
def requests_log():
    return []


@pytest.fixture
def app(page: Page, requests_log):
    """Open the page with mocked backend. Returns the Playwright page."""

    def serve_html(route):
        route.fulfill(status=200, content_type="text/html", body=PAGE_PATH.read_text(encoding="utf-8"))

    def serve_clients(route):
        requests_log.append(route.request.url)
        route.fulfill(status=200, content_type="application/json", json=CLIENTS)

    def serve_goods(route):
        requests_log.append(route.request.url)
        client_id = re.search(r"/api/clients/([^/]+)/goods", route.request.url).group(1)
        route.fulfill(status=200, content_type="application/json", json=GOODS.get(client_id, []))

    page.route(f"{ORIGIN}/", serve_html)
    page.route(f"{ORIGIN}/api/clients", serve_clients)
    page.route(f"{ORIGIN}/api/clients/*/goods", serve_goods)

    page.goto(f"{ORIGIN}/")
    # wait until clients have been loaded into the select
    expect(page.locator("#clientSelect option")).to_have_count(len(CLIENTS) + 1)
    return page


def options(page: Page, selector: str):
    """Return [(value, text), ...] for all <option> in a select."""
    return page.locator(f"{selector} option").evaluate_all(
        "els => els.map(e => [e.value, e.textContent])"
    )


# ---------------------------------------------------------------- initial state

def test_clients_are_loaded_with_id_as_value_and_name_as_text(app):
    assert [list(o) for o in options(app, "#clientSelect")] == [
        ["", "-- Choose a client --"],
        ["1", "Acme Ltd"],
        ["2", "Beta Corp"],
    ]


def test_goods_and_submit_are_disabled_initially(app):
    expect(app.locator("#goodsSelect")).to_be_disabled()
    expect(app.locator("#submitBtn")).to_be_disabled()
    expect(app.locator("#goodsSelect")).to_have_value("")


# ------------------------------------------------------------ selecting client

def test_selecting_client_enables_goods_and_submit(app):
    app.select_option("#clientSelect", "1")

    expect(app.locator("#goodsSelect")).to_be_enabled()
    expect(app.locator("#submitBtn")).to_be_enabled()


def test_goods_are_fetched_for_the_selected_client(app, requests_log):
    app.select_option("#clientSelect", "2")
    expect(app.locator("#goodsSelect")).to_be_enabled()

    assert f"{ORIGIN}/api/clients/2/goods" in requests_log


def test_goods_options_use_id_as_value_and_show_name_and_price(app):
    app.select_option("#clientSelect", "1")
    expect(app.locator("#goodsSelect")).to_be_enabled()

    assert [list(o) for o in options(app, "#goodsSelect")] == [
        ["", "-- Choose a product --"],
        ["10", "Chair ($49.9)"],
        ["20", "Table ($120)"],
    ]


def test_choosing_a_good_gives_its_id_not_its_name(app):
    app.select_option("#clientSelect", "1")
    expect(app.locator("#goodsSelect")).to_be_enabled()

    app.select_option("#goodsSelect", "20")

    expect(app.locator("#goodsSelect")).to_have_value("20")
    assert app.locator("#clientSelect").input_value() == "1"


def test_switching_client_reloads_goods(app):
    app.select_option("#clientSelect", "1")
    expect(app.locator("#goodsSelect option")).to_have_count(3)

    app.select_option("#clientSelect", "2")
    expect(app.locator("#goodsSelect option")).to_have_count(2)

    assert [list(o) for o in options(app, "#goodsSelect")] == [
        ["", "-- Choose a product --"],
        ["30", "Lamp ($15)"],
    ]


# ----------------------------------------------------------------- deselecting

def test_clearing_the_client_locks_goods_and_submit_again(app):
    app.select_option("#clientSelect", "1")
    expect(app.locator("#goodsSelect")).to_be_enabled()

    app.select_option("#clientSelect", "")

    expect(app.locator("#goodsSelect")).to_be_disabled()
    expect(app.locator("#submitBtn")).to_be_disabled()
    assert [list(o) for o in options(app, "#goodsSelect")] == [["", "-- Select a client first --"]]


def test_goods_are_locked_while_loading(page: Page):
    """While the goods request is pending the select must stay disabled."""
    release = {}

    def serve_html(route):
        route.fulfill(status=200, content_type="text/html", body=PAGE_PATH.read_text(encoding="utf-8"))

    def serve_clients(route):
        route.fulfill(status=200, content_type="application/json", json=CLIENTS)

    def serve_goods(route):
        release["route"] = route  # hold the response

    page.route(f"{ORIGIN}/", serve_html)
    page.route(f"{ORIGIN}/api/clients", serve_clients)
    page.route(f"{ORIGIN}/api/clients/*/goods", serve_goods)
    page.goto(f"{ORIGIN}/")
    expect(page.locator("#clientSelect option")).to_have_count(3)

    page.select_option("#clientSelect", "1")

    expect(page.locator("#goodsSelect")).to_be_disabled()
    expect(page.locator("#goodsSelect")).to_contain_text("Loading goods")

    release["route"].fulfill(status=200, content_type="application/json", json=GOODS["1"])
    expect(page.locator("#goodsSelect")).to_be_enabled()

  