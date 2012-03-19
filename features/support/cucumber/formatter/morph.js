MM = {}

MM.showStats = function(stats){
  $('#totals').text(stats);
}

MM.labelFeatures = function(){
  $('#features .feature').each(function(index, feature){
    feature = $(feature);
    var label = null;

    feature.find('.step').each(function(index, step){
      step = $(step);

      if(step.hasClass('pending')){
        label = 'pending';
      } else if(step.hasClass('undefined')){
        label = 'undefined';
      } else if(step.hasClass('failed')) {
        label = 'failed';
      }

      return (label == null); // This each loop will end when (label != null)
    });

    if(label == null) label = 'passed'

    feature.find('h2').append($('#status-labels .' + label).clone());
  });
}

MM.showTOC = function(){
  $('.feature').each(function(index, feature){
    feature = $(feature);
    var div = $(document.createElement('div'));
    var feature_name = feature.find('.feature-name').parent().first().html().replace(/Feature:/,'');
    var bookmark = feature.find('.bookmark').first().attr('name');
    div.html(feature_name);
    div.addClass('toc-item');
    $('#toc').append(div);
    div.find('.feature-name').wrap("<a href='#" + bookmark + "'/>");
  });
}