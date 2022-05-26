<script lang="ts">
  import { onMount } from "svelte"
  import Fa from "svelte-fa"
  import { Link } from "svelte-navigator"

  import {
    faComment,
    faHeart,
    faChartBar,
    faImage,
  } from "@fortawesome/free-regular-svg-icons"
  import { faRetweet, faPlus } from "@fortawesome/free-solid-svg-icons"
  import inf from "./assets/inf.gif"

  export let auth
  export let principal
  export let signIn

  let post = ""
  let errorResponse = ""
  let feed = []
  let processing = false
  let showBetForm = false
  let startDate = ""
  let endDate = ""
  let outcomes = [
    { id: 1, label: "Outcome 1", value: "" },
    { id: 2, label: "Outcome 2", value: "" },
  ]

  const submitPost = async () => {
    processing = true
    let initData = {
      id: 0,
      author: {
        principal,
        picture: "",
        handle: "",
        name: "",
      },
      content: post,
      postType: { post: null },
    }
    const r = await $auth.actor.submitPost(initData)
    console.log(r)
    processing = false
    post = ""
    getFeed()
  }

  const splitCamelCaseToString = (s) => {
    return s
      .split(/(?=[A-Z])/)
      .map((p) => {
        return p[0].toUpperCase() + p.slice(1)
      })
      .join(" ")
  }

  const submitMarket = async () => {
    processing = true
    let labels = outcomes.map((o) => o.value)

    let i = 0
    let probabilities = []
    for (; i < labels.length; i++) {
      probabilities.push(1.0 / labels.length)
    }

    const marketInitData = {
      id: 0,
      title: post,
      description: post,
      labels,
      images: [],
      probabilities: probabilities,
      category: { crypto: null },
      liquidity: 1000,
      startDate: Date.parse(startDate) * 1_000_000,
      endDate: Date.parse(endDate) * 1_000_000,
      imageUrl: "nothing",
      collateralType: { seers: null },
      author: "",
    }
    const resp = await $auth.actor.createMarket(marketInitData)
    processing = false

    if (resp["err"]) {
      errorResponse =
        "Error: " + splitCamelCaseToString(Object.keys(resp["err"]).toString())
    } else {
      console.log(resp)
    }
  }

  const getFeed = async () => {
    feed = await $auth.actor.getFeed()
    feed = feed.reverse()
    console.log(feed)
  }

  function parseTwitterDate(tdate) {
    var system_date = new Date(tdate)
    var user_date = new Date()

    var diff = Math.floor((Number(user_date) - Number(system_date)) / 1000)
    if (diff <= 1) {
      return "now"
    }
    if (diff < 60) {
      return diff + "s"
    }
    // if (diff < 40) {
    //   return "half a minute ago"
    // }
    // if (diff < 60) {
    //   return "less than a minute ago"
    // }
    if (diff <= 90) {
      return "1m"
    }
    if (diff <= 3540) {
      return Math.round(diff / 60) + "m"
    }
    if (diff <= 5400) {
      return "1h"
    }
    if (diff <= 86400) {
      return Math.round(diff / 3600) + "h"
    }
    if (diff <= 129600) {
      return "1d"
    }
    if (diff < 604800) {
      return Math.round(diff / 86400) + "d"
    }
    if (diff <= 777600) {
      return "1w"
    }
    return "on " + system_date
  }

  onMount(getFeed)
</script>

<div
  style="justify-content: center; display: flex;width: 100%; margin-top: 20px; flex-direction:column; align-items:center; gap: 20px"
>
  <div class="rowUser">
    <div style="width: 100%; margin: 0px; padding: 5px">
      <textarea
        bind:value={post}
        rows="3"
        style="width: 100%; font-size: 1.3em; background: black;color:white;border: 0px solid rgb(90, 58, 81); padding: 5px; border-radius: 15px"
        placeholder={showBetForm ? "Ask a question..." : "What's happening?"}
      />
      {#if showBetForm}
        <div
          style="display:flex; flex-direction: column; width: 100%; height: fit-content; border: 1px solid rgb(47, 51, 54); border-radius: 16px; align-items:flex-end"
        >
          <div
            style="display:flex; width: 100%; height: fit-content; border: 0px solid rgb(47, 51, 54); align-items:flex-end"
          >
            <div
              style="display: flex; flex-direction:column; flex-grow: 1; justify-content:space-evenly"
            >
              {#each outcomes as outcome (outcome.id)}
                <div
                  style="height: 50px; border: 1px solid rgb(51, 54, 57); border-radius:4px; padding: 5px; margin: 15px"
                >
                  <input
                    bind:value={outcome.value}
                    type="text"
                    placeholder={outcome.label}
                    style="background: black; border: 0px; width: 100%; height: 100%; color:white; font-size: 1.2em;"
                  />
                </div>
              {/each}
            </div>

            <div
              style="width: 50px; height: 60px  ; display:flex; justify-content:center; align-items:flex-end; "
            >
              <div
                style="height: 100%"
                on:click={() => {
                  outcomes.push({
                    id: outcomes.length + 1,
                    label: `Outcome ${outcomes.length + 1}`,
                    value: "",
                  })
                  outcomes = outcomes
                  console.log(outcomes)
                }}
              >
                <Fa icon={faPlus} scale={1.3} />
              </div>
            </div>
          </div>
          <div
            style="display:flex; width: 100%; height: 70px; border-top: 1px solid rgb(47, 51, 54); align-items:flex-end;"
          >
            <div
              style="display:flex; width: 100%; height: 100%; padding: 0px 5px;"
            >
              <div
                style="width: 50%; height: 100%; border-right: 1px solid rgb(47, 51, 54); display:flex; flex-direction:column; justify-content:center; padding: 0px 10px"
              >
                <label for="start" style="width: 100%; color:grey"
                  >Start date:</label
                >

                <input
                  type="date"
                  id="start"
                  bind:value={startDate}
                  min="2022-01-01"
                  max="2050-01-01"
                  style="background: black; color:grey; border: 0px; font-size: 1.5em"
                />
              </div>
              <div
                style="width: 50%; height: 100%; border-right: 0px solid rgb(47, 51, 54); display:flex; flex-direction:column; justify-content:center; padding: 0px 10px"
              >
                <label for="start" style="width: 100%; color:grey"
                  >End date:</label
                >

                <input
                  type="date"
                  id="end"
                  bind:value={endDate}
                  min="2022-01-01"
                  max="2050-01-01"
                  style="background: black; color:grey; border: 0px; font-size: 1.5em"
                />
              </div>
            </div>
          </div>
        </div>
      {/if}
      <div style="display:flex">
        <div
          style="display:flex; text-align:center; align-items:center; width: 70px; margin-left: 50px "
          on:click={() => {
            showBetForm = showBetForm ? false : true
          }}
        >
          <Fa icon={faImage} scale={1.2} />
        </div>
        <div
          style="display:flex; text-align:center; align-items:center; width: 70px"
          on:click={() => {
            showBetForm = showBetForm ? false : true
          }}
        >
          <Fa icon={faChartBar} scale={1.2} />
        </div>

        {#if principal === ""}
          <div
            style="display:flex; text-align:end; justify-content:end; flex-grow: 1"
          >
            <button class="btn-grad" on:click={signIn}>Login</button>
            <div style="text-align:end;color:red">
              {errorResponse}
            </div>
          </div>
        {:else if processing}
          <div
            style="display:flex; text-align:end; justify-content:end; flex-grow: 1"
          >
            <button
              class="btn-grad"
              on:click={() => 0}
              style="width: 100px; overflow:hidden"
            >
              <img
                src={inf}
                alt="inf"
                style="width: 150px; height: 400%; margin: -100%;"
              />
            </button>
            <div style="text-align:end;color:red">
              {errorResponse}
            </div>
          </div>
        {:else}
          <div
            style="display:flex; text-align:end; justify-content:end; flex-grow: 1"
          >
            <button
              class="btn-grad"
              on:click={() => {
                if (showBetForm) {
                  submitMarket()
                } else {
                  submitPost()
                }
              }}>Post</button
            >
            <div style="text-align:end;color:red">
              {errorResponse}
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>
  <div
    style="width: 100%; display:flex; justify-content:center; flex-direction:column; align-items:center; gap: 10px"
  >
    <div class="rowUser">
      <div
        style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
      >
        <div style="padding: 5px; margin: 5px; height: 100%">
          <a href={`/profile/principal`}>
            <img
              src="http://pa1.narvii.com/6694/f16bc252592bb4f3dc37520e28e16a06ee8dda18_00.gif"
              alt="avatar"
              style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
            />
          </a>
        </div>
        <div style="flex-grow: 1; justify-content: start; text-align:start">
          <div style="display:flex; gap: 5px;">
            <div>
              <a href={`/profile/principal`}>Motoko</a>
            </div>
            <div style="color:grey">
              <a href={`/profile/principal`} style="color:grey"> @motoko </a>
            </div>
            <div style="color:grey">
              - {parseTwitterDate(parseInt("4200000000000000000") / 1_000_000)}
            </div>
            <div style="color:grey">- retweeted by @marcio</div>
          </div>
          <Link to={`/profile/post/10#main`} style="width: 100%">
            <div style="width: 100%; text-align:start; padding: 15px 0px">
              What will be the price of ETH on September 2022?
            </div>
          </Link>
          <div>
            <div style="width: 100%; display:flex">
              <div
                style="background: #39CCCC; width: 80%; padding: 5px; margin: 2px; border: 1px solid black; border-radius: 5px; color:black"
              >
                <span style="width: 50px">-></span> Less than 3k
              </div>
              <div
                style="flex-grow: 1; justify-content:flex-end; text-align:end; margin-right: 30px; padding: 5px"
              >
                0.80 &Sigma;
              </div>
            </div>
            <div style="width: 100%; display:flex">
              <div
                style="background: #01FF70; width: 20%; padding: 5px; margin: 2px; border: 1px solid black; border-radius: 5px; color:black"
              >
                <span style="min-width: 200px">&nbsp;</span> More than 3k
              </div>
              <div
                style="flex-grow: 1; justify-content:flex-end; text-align:end; margin-right: 30px; padding: 5px"
              >
                0.20 &Sigma;
              </div>
            </div>
            <div
              style="display:flex; text-align:end; justify-content:start; flex-grow: 1"
            >
              <button
                class="btn-grad"
                style="background: black; padding: 5px; margin: 15px 0px; color: white"
                on:click={signIn}>Buy</button
              >
              <div style="text-align:end;color:red">
                {errorResponse}
              </div>
            </div>
          </div>
          <div
            style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
          >
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faComment} /></div>
              <div>15</div>
            </div>
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faRetweet} /></div>
              <div>40</div>
            </div>
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faHeart} /></div>
              <div>80</div>
            </div>
          </div>
        </div>
      </div>
      <div
        style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
      >
        <div style="padding: 5px; margin: 5px; height: 100%">
          <a href={`/profile/principal`}>
            <img
              src="http://pa1.narvii.com/6694/f16bc252592bb4f3dc37520e28e16a06ee8dda18_00.gif"
              alt="avatar"
              style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
            />
          </a>
        </div>
        <div style="flex-grow: 1; justify-content: start; text-align:start">
          <div style="display:flex; gap: 5px;">
            <div>
              <a href={`/profile/principal`}>Motoko</a>
            </div>
            <div style="color:grey">
              <a href={`/profile/principal`} style="color:grey"> @motoko </a>
            </div>
            <div style="color:grey">
              - {parseTwitterDate(parseInt("4200000000000000000") / 1_000_000)}
            </div>
            <div style="color:grey">- retweeted by @dom</div>
          </div>
          <Link to={`/profile/post/10#main`} style="width: 100%">
            <div style="width: 100%; text-align:start; padding: 15px 0px">
              New pic, hope you like my new glasses.
            </div>
          </Link>
          <div>
            <!-- <iframe
              width="560"
              height="315"
              src="https://www.youtube.com/embed/uBFdSyDkPOU"
              title="YouTube video player"
              frameborder="0"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowfullscreen
            /> -->
            <img
              src="https://es.web.img3.acsta.net/newsv7/19/06/14/14/41/2417858.jpg"
              alt="motoko"
              style="width: 80%; border-radius: 15px"
            />
          </div>
          <div
            style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
          >
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faComment} /></div>
              <div>300</div>
            </div>
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faRetweet} /></div>
              <div>20</div>
            </div>
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faHeart} /></div>
              <div>30</div>
            </div>
          </div>
        </div>
      </div>
      <div
        style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
      >
        <div style="padding: 5px; margin: 5px; height: 100%">
          <a href={`/profile/principal`}>
            <img
              src="http://pa1.narvii.com/6694/f16bc252592bb4f3dc37520e28e16a06ee8dda18_00.gif"
              alt="avatar"
              style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
            />
          </a>
        </div>
        <div style="flex-grow: 1; justify-content: start; text-align:start">
          <div style="display:flex; gap: 5px;">
            <div>
              <a href={`/profile/principal`}>Motoko</a>
            </div>
            <div style="color:grey">
              <a href={`/profile/principal`} style="color:grey"> @motoko </a>
            </div>
            <div style="color:grey">
              - {parseTwitterDate(parseInt("4200000000000000000") / 1_000_000)}
            </div>
            <div style="color:grey">- retweeted by @dom</div>
          </div>
          <Link to={`/profile/post/10#main`} style="width: 100%">
            <div style="width: 100%; text-align:start; padding: 15px 0px">
              Binance Bahrain has received a Category 4 license as a
              crypto-asset service provider (CASP) from the Central Bank of
              Bahrain (CBB). The Category 4 license will allow Binance Bahrain
              to provide a full range of crypto-asset exchange services.
              https://binance.com/en/blog/ecosys
            </div>
          </Link>
          <div
            style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
          >
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faComment} /></div>
              <div>300</div>
            </div>
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faRetweet} /></div>
              <div>20</div>
            </div>
            <div style="width: 50px; display:flex; gap: 15px">
              <div><Fa icon={faHeart} /></div>
              <div>30</div>
            </div>
          </div>
        </div>
      </div>
      {#each feed as item, i}
        {#if i != feed.length - 1}
          {#if item.citing.length > 0}
            <div
              style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
            >
              <div style="padding: 5px; margin: 5px; height: 100%">
                <a href={`/profile/${item.author.principal}`}>
                  <img
                    src={item.author.picture}
                    alt="avatar"
                    style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
                  />
                </a>
              </div>
              <div
                style="flex-grow: 1; justify-content: start; text-align:start"
              >
                <div style="display:flex; gap: 5px;">
                  <div>
                    <a href={`/profile/${item.author.principal}`}
                      >{item.author.name}</a
                    >
                  </div>
                  <div style="color:grey">
                    <a
                      href={`/profile/${item.author.principal}`}
                      style="color:grey"
                    >
                      @{item.author.handle}
                    </a>
                  </div>
                  <div style="color:grey">
                    - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                  </div>
                  <div style="color:grey">- Retweeted</div>
                </div>
                <Link to={`/profile/post/${item.id}#main`} style="width: 100%">
                  <div style="width: 100%; text-align:start; padding: 5px 0px">
                    {item.citing[0].content}
                  </div>
                </Link>
                <div
                  style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
                >
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faComment} /></div>
                    <div>{item.replies.length}</div>
                  </div>
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faRetweet} /></div>
                    <div>0</div>
                  </div>
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faHeart} /></div>
                    <div>{item.likes.length}</div>
                  </div>
                </div>
              </div>
            </div>
          {:else}
            <div
              style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
            >
              <div style="padding: 5px; margin: 5px; height: 100%">
                <a href={`/profile/${item.author.principal}`}>
                  <img
                    src={item.author.picture}
                    alt="avatar"
                    style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
                  />
                </a>
              </div>
              <div
                style="flex-grow: 1; justify-content: start; text-align:start"
              >
                <div style="display:flex; gap: 5px;">
                  <div>
                    <a href={`/profile/${item.author.principal}`}
                      >{item.author.name}</a
                    >
                  </div>
                  <div style="color:grey">
                    <a
                      href={`/profile/${item.author.principal}`}
                      style="color:grey"
                    >
                      @{item.author.handle}
                    </a>
                  </div>
                  <div style="color:grey">
                    - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                  </div>
                </div>
                <Link to={`/profile/post/${item.id}#main`} style="width: 100%">
                  <div style="width: 100%; text-align:start; padding: 5px 0px">
                    {item.content}
                  </div>
                </Link>
                <div
                  style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
                >
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faComment} /></div>
                    <div>{item.replies.length}</div>
                  </div>
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faRetweet} /></div>
                    <div>0</div>
                  </div>
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faHeart} /></div>
                    <div>{item.likes.length}</div>
                  </div>
                </div>
              </div>
            </div>
          {/if}
        {:else if item.citing.length > 0}
          <div
            style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center;"
          >
            <div style="padding: 5px; margin: 5px; height: 100%">
              <a href={`/profile/${item.author.principal}`}>
                <img
                  src={item.author.picture}
                  alt="avatar"
                  style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
                />
              </a>
            </div>
            <div style="flex-grow: 1; justify-content: start; text-align:start">
              <div style="display:flex; gap: 5px;">
                <div>
                  <a href={`/profile/${item.author.principal}`}
                    >{item.author.name}</a
                  >
                </div>
                <div style="color:grey">
                  <a
                    href={`/profile/${item.author.principal}`}
                    style="color:grey"
                  >
                    @{item.author.handle}
                  </a>
                </div>
                <div style="color:grey">
                  - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                </div>
                <div style="color:grey">- Retweeted</div>
              </div>
              <Link to={`/profile/post/${item.id}`} style="width: 100%">
                <div style="width: 100%; text-align:start; padding: 5px 0px">
                  {item.citing.content}
                </div>
              </Link>
              <div
                style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:gray"
              >
                <div style="width: 50px; display:flex; gap: 15px;">
                  <div><Fa icon={faComment} /></div>
                  <div>{item.replies.length}</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faRetweet} /></div>
                  <div>0</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faHeart} /></div>
                  <div>{item.likes.length}</div>
                </div>
              </div>
            </div>
          </div>
        {:else}
          <div
            style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center;"
          >
            <div style="padding: 5px; margin: 5px; height: 100%">
              <a href={`/profile/${item.author.principal}`}>
                <img
                  src={item.author.picture}
                  alt="avatar"
                  style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
                />
              </a>
            </div>
            <div style="flex-grow: 1; justify-content: start; text-align:start">
              <div style="display:flex; gap: 5px;">
                <div>
                  <a href={`/profile/${item.author.principal}`}
                    >{item.author.name}</a
                  >
                </div>
                <div style="color:grey">
                  <a
                    href={`/profile/${item.author.principal}`}
                    style="color:grey"
                  >
                    @{item.author.handle}
                  </a>
                </div>
                <div style="color:grey">
                  - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                </div>
              </div>
              <Link to={`/profile/post/${item.id}`} style="width: 100%">
                <div style="width: 100%; text-align:start; padding: 5px 0px">
                  {item.content}
                </div>
              </Link>
              <div
                style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:gray"
              >
                <div style="width: 50px; display:flex; gap: 15px;">
                  <div><Fa icon={faComment} /></div>
                  <div>{item.replies.length}</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faRetweet} /></div>
                  <div>0</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faHeart} /></div>
                  <div>{item.likes.length}</div>
                </div>
              </div>
            </div>
          </div>
        {/if}
      {/each}
    </div>
  </div>
</div>
