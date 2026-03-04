::EventInfo.News <- {
	m = {
		NewsManager = null
	},

	function init()
	{
		this.m.NewsManager = ::World.Statistics;
	}

	function anyNews()
	{
		if (this.m.NewsManager.isNewsReady()) {
			return "Yes";
		}
		else {
			return "No";
		}
	}

	function getNews()
	{
		local newsList = this.m.NewsManager.getNews();
		local ret = [];

		if (newsList == null || newsList.len() == 0) {
			return [];
		}

		foreach (news in newsList) {
			local newNews = {
				name = ::EventInfo.Events.createHumanReadableEventName(news.Type)
			};

			ret.append(newNews);
		};

		return ret;
	}
}