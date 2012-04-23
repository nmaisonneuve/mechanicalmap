var Url = Class.extend({

    init:function (url) {
        this.url = url;
        this.score = 0.0;   //not normalized
        this.sentences = [];

    },

    add_influence:function (sentence) {
        var source = sentence.get_source(this.url);
        source.sentence_idx = sentence.idx;
        source.sentence = sentence.content;
        this.sentences.push(source);
    },

    compute_influence:function () {
        var me = this;
        $.each(this.sentences, function (i, sentence) {
            me.score += sentence.score;
        });
        console.log("influence for " + this.url + ": " + this.score);
    }
});

var Sentence = Class.extend({
        init:function (text, words) {
            this.content = text;
            this.signature = words;
            this.best_score = 0;
            this.sources = [];
            this.idx = 0;
            this.copy_source = "bing";
        },

        get_source:function (url) {
            var right_source;
            $.each(this.sources, function (i, source) {
                if (source.url == url) {
                    right_source = source;
                }
            });
            return right_source;
        },

        sort_sources:function () {
            this.sources.sort(function (a, b) {
                if (a.score > b.score) return -1;
                if (a.score < b.score) return 1;
                return 0;
            });

            if (this.sources.length > 0) {
                this.best_score = this.sources[0].score;
            }
        },

        add_source:function (source) {
            this.sources.push(source);
        },

        compute_similarity_with:function (content) {
            return this.compute_similarity(this.signature, content);
        },

        compute_similarity:function (ref_words, result_words) {
            var tmp;
           // if (ref_words.length < result_words.length) {
                tmp = ref_words;
                ref_words = result_words;
                result_words = tmp;
            //}*/

            var matching = 0.0;
            $.each(result_words, function (i, word) {
                if ($.inArray(word, ref_words) != -1)
                    matching++;
            });
            var score = matching / result_words.length;
            //console.log([ref_words,result_words,score]);
            return (score);
        },

        find_copies:function (callback) {
            var filtered_raw = this.signature.map(
                function (a) {
                    return ("'" + a + "'");
                }).join(" ");
            // join("' '");//.join("' '"); //;//
            console.log("Fetch query: " + filtered_raw+" to "+this.copy_source);
            var query = encodeURIComponent(filtered_raw);
            if (this.copy_source == "bing") {
                this.find_copy_from_bing(query, callback);
            } else {
                this.find_copy_from_google(query, callback);
            }
        },

        find_copy_from_bing:function (query, callback) {
            $.ajax({
                url:"http://api.search.live.net/json.aspx?sources=web&JsonType=callback&JsonCallback=?&Appid=57F44339DF91A8E625E6BE366FB083C55681DF51&query=" + query,
                dataType:'jsonp',
                success:function (data) {
                    var results = [];
                    if ((typeof data.SearchResponse.Web !== 'undefined') && (data.SearchResponse.Web.Total > 0)) {
                        $.each(data.SearchResponse.Web.Results, function (i, result) {
                            if (typeof result.Description !== 'undefined') {
                                results.push({
                                    url:result.Url,
                                    content:result.Description
                                });
                            }
                        });
                    }
                    callback(results);
                }
            });
        },

        find_copy_from_google:function (query, callback) {
            $.ajax({
                url:"http://ajax.googleapis.com/ajax/services/search/web?v=1.0&key=ABQIAAAAEDqSJ7sjOq1o3M9HFMUctBRHLLJL8B9uYR_4q6aVV5NleiQ1chSzfXCk5YpmwpqBSxo0Kjq3kiU-4w&q=" + query,
                dataType:'jsonp',
                success:function (data) {
                    var results = [];
                    $.each(data.responseData.results, function (i, result) {
                        results.push({
                            url:result.url,
                            content:result.content
                        });
                    });
                    callback(results);
                }
            });
        }
    })
    ;