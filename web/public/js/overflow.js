var correctTitlesOverflow = function(){
    $('.slides .n2e-slide-title.present h1').each(function(){
        correctTitleOverflow($(this));
    });
};

var correctTitleOverflow = function(element, maxheight){
    while (isOverflow(element, maxheight)){
        var fontsize = element.css('font-size');
        var number = parseInt(fontsize.split('px')[0]);
        var newsize = number - 20;
        var newfontsize = "" + newsize + "px"
        element.css({'font-size': newfontsize});
    };
};

var correctContentsOverflow = function(){
    $('.slides .n2e-slide-content.present div.container').each(function(){
        var maxheight = $(this).height();
        var contentSlide = $(this).parent();
        var mainSlide = contentSlide.parent();
        correctContentOverflow($(this), maxheight, mainSlide);
    });
};

var correctContentOverflow = function(element, maxheight, mainSlide, aOverflowNode){
    element.parent().removeClass("overflow");
    var currentOverflowNode;
    while(isHeightOverflow(element, maxheight)){
        currentOverflowNode = currentOverflowNode || getCurrentOverflowNode(element, mainSlide, aOverflowNode);
        if (element.children().length <= 1){
            return correctOrphanElementOverflow(element, maxheight, mainSlide, currentOverflowNode);
        }else{
            var child = element.children().last();
            currentOverflowNode.prepend(child.remove());
        }
    }
}

var getCurrentOverflowNode = function(element, mainSlide, aOverflowNode){
    if (!aOverflowNode){
        return getOverflowSectionContainer(mainSlide);
    }else{
        var cloned = element.clone();
        cloned.html("");
        aOverflowNode.prepend(cloned);
        aOverflowNode = cloned;
        return aOverflowNode;
    }
}

var correctOrphanElementOverflow = function(element, maxheight, mainSlide, aOverflowNode){
    if (element[0].tagName == 'P' || element[0].tagName == 'LI'){
        return correctParagraphElementOverflow(element, maxheight, mainSlide, aOverflowNode);
    }
    var child = element.children().last();
    return correctContentOverflow(child, maxheight, mainSlide, aOverflowNode);
};

var correctParagraphElementOverflow = function(element, maxheight, mainSlide, aOverflowNode){
    var text = element.html();
    var array = text.split(" ");
    var subtext = array.slice(0, array.length / 2).join(" ");
    var tail = array.slice(array.length / 2, array.length).join(" ");
    element.html(subtext + '...');
    aOverflowNode.html('...' + tail);
    aOverflowNode = aOverflowNode.parent();
    return correctContentOverflow(element, maxheight, mainSlide, aOverflowNode);
}

var isTheContainer = function(element){
    return element.is('div') && element.hasClass('container');
}

var getOverflowSectionContainer = function(mainSlide){
    var overflowSlide = mainSlide.find("section.overflow");
    if (!overflowSlide.length){
        return createAndAttachOverflowContainer(mainSlide);
    }else{
        return overflowSlide.find("div.container").last();
    }
}

var createAndAttachOverflowContainer = function(mainSlide){
    var overflowSlide = createOverflowSection();
    var container = createOverflowContainer();
    overflowSlide.append(container);
    mainSlide.append(overflowSlide);
    return container;
}

var createOverflowContainer = function(){
    var container = $('<div></div>');
    container.addClass('container');
    return container;
}

var createOverflowSection = function(){
    var overflowSlide = $('<section></section>');
    overflowSlide.addClass("n2e-slide-content overflow");
    return overflowSlide;
}

var isOverflow = function(element, maxheight){
    return  isHeightOverflow(element, maxheight) || isWidthOverflow(element);
};

var isHeightOverflow = function(element, maxheight){
    var aux = element[0];
    if(!aux){
        aux = element;
    }
    var scrollHeight = aux.scrollHeight;
    var height = maxheight || element.height();
    return  scrollHeight > height;
}

var isWidthOverflow = function(element){
    return element[0].scrollWidth > element.width();
}

