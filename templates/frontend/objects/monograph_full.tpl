<div class="obj_monograph_full">

    {* Olitas *}
    <div class="book-olitas">
      <img src="http://localhost:8000/public/presses/1/olitas.png" alt="">
    </div>

    <div class="book-presentation-container">
      <div class="book-presentation-area">
      {* Cover *}
        <div class="item cover caratula">
          {assign var="coverImage" value=$publication->getLocalizedData('coverImage')}
          <img 
          src="{$publication->getLocalizedCoverImageThumbnailUrl($monograph->getData('contextId'))}" 
          alt="{$coverImage.altText|escape|default:''}" 
          >
        </div>

      {* Written Presentation *}
        <div class="book-written-presentation">
        {if $series}
          <a href="{url page="catalog" op="series" path=$series->getPath()}" class="book-series">
              {$series->getLocalizedFullTitle()|escape}
							</a>
        {/if}
          <div class="book-publication-date">
          <span>·{$firstPublication->getData('datePublished')|date_format:"%Y"}·</span>
          </div>
          <h1 class="title">
            {$publication->getLocalizedTitle()|escape}
          </h1>
          <h2 class="subtitle">
            {$publication->getLocalizedData('subtitle')|escape}
          </h2>

          <h3 class>
			{include file="frontend/components/authors.tpl" authors=$publication->getData('authors')}
          </h3>
          <div class="book-abstract">
              {$publication->getLocalizedData('abstract')|strip_unsafe_html}

              <button class="main-btn">
              Descargar
              </button>
          </div>
        </div>


      {* Book secondary Info Container *}

      </div>



    </div>

        <hr class="book-separator">

      <div class="book-secondary-container" v-scope="{ infoType: 'info' }" >
        <div class="book-secondary-picker" >
          <button 
          :class="{ 'underlined': infoType === 'authors', 'faded': infoType !== 'authors' }"
          @click="{ infoType = 'authors'}"
          >
            Autores
          </button>
          <button 
          :class="{ 'underlined': infoType === 'info', 'faded': infoType !== 'info' }"
          @click="{ infoType = 'info'}"
          >
            Info
          </button>
          <button 
          :class="{ 'underlined': infoType === 'praise', 'faded': infoType !== 'praise' }"
          @click="{ infoType = 'praise'}"
          >
            Reseñas
          </button>
      </div>
        <div class="book-authors"
        v-bind="{ 'shown': infoType === 'authors', 'hidden': infoType !== 'authors' }"
        >
        {assign var="hasBiographies" value=0}
        {foreach from=$publication->getData('authors') item=author}
          {if $author->getLocalizedBiography()}
            {assign var="hasBiographies" value=$hasBiographies+1}
          {/if}
        {/foreach}
        {if $hasBiographies}
          <div class="item author_bios">
            {foreach from=$publication->getData('authors') item=author}
              {if $author->getLocalizedBiography()}
                <div class="sub_item">
                  <h2 class="label">
                    {if $author->getLocalizedAffiliation()}
                      {capture assign="authorName"}{$author->getFullName()|escape}{/capture}
                      {capture assign="authorAffiliation"}<span class="affiliation">{$author->getLocalizedAffiliation()|escape}</span>{/capture}
                      {translate key="submission.authorWithAffiliation" name=$authorName affiliation=$authorAffiliation}
                    {else}
                      {$author->getFullName()|escape}
                    {/if}
                  </h2>
                  <div class="author-bio">
                    {$author->getLocalizedBiography()|strip_unsafe_html}
                  </div>
                </div>
              {/if}
            {/foreach}
          </div>
        {/if}
        </div>


        <div class="book-info"
        v-bind="{ 'shown': infoType === 'info', 'hidden': infoType !== 'info' }"
        >
	{if count($publicationFormats)}
				{foreach from=$publicationFormats item="publicationFormat"}
					{if $publicationFormat->getIsApproved()}

						{assign var=identificationCodes value=$publicationFormat->getIdentificationCodes()}
						{assign var=identificationCodes value=$identificationCodes->toArray()}
						{assign var=publicationDates value=$publicationFormat->getPublicationDates()}
						{assign var=publicationDates value=$publicationDates->toArray()}
						{assign var=hasPubId value=false}
						{foreach from=$pubIdPlugins item=pubIdPlugin}
							{assign var=pubIdType value=$pubIdPlugin->getPubIdType()}
							{if $publicationFormat->getStoredPubId($pubIdType)}
								{assign var=hasPubId value=true}
								{break}
							{/if}
						{/foreach}
						{if $publicationFormat->getDoi()}
							{assign var=hasPubId value=true}
						{/if}

						{* Skip if we don't have any information to print about this pub format *}
						{if !$identificationCodes && !$publicationDates && !$hasPubId && !$publicationFormat->getPhysicalFormat()}
							{continue}
						{/if}

						<div class="item publication_format">

							{* Only add the format-specific heading if multiple publication formats exist *}
							{if count($publicationFormats) > 1}
								<h2 class="pkp_screen_reader">
									{assign var=publicationFormatName value=$publicationFormat->getLocalizedName()}
									{translate key="monograph.publicationFormatDetails" format=$publicationFormatName|escape}
								</h2>

								<div class="sub_item item_heading format">
									<div class="label">
										{$publicationFormat->getLocalizedName()|escape}
									</div>
								</div>
							{else}
								<h2 class="pkp_screen_reader">
									{translate key="monograph.miscellaneousDetails"}
								</h2>
							{/if}


							{* DOI's and other identification codes *}
							{if $identificationCodes}
								{foreach from=$identificationCodes item=identificationCode}
									<div class="sub_item identification_code">
										<h3 class="label">
											{$identificationCode->getNameForONIXCode()|escape}
										</h3>
										<div class="value">
											{$identificationCode->getValue()|escape}
										</div>
									</div>
								{/foreach}
							{/if}

							{* Dates of publication *}
							{if $publicationDates}
								{foreach from=$publicationDates item=publicationDate}
									<div class="sub_item date">
										<h3 class="label">
											{$publicationDate->getNameForONIXCode()|escape}
										</h3>
										<div class="value">
											{assign var=dates value=$publicationDate->getReadableDates()}
											{* note: these dates have dateFormatShort applied to them in getReadableDates() if they need it *}
											{if $publicationDate->isFreeText() || $dates|@count == 1}
												{$dates[0]|escape}
											{else}
												{* @todo the &mdash; ought to be translateable *}
												{$dates[0]|escape}&mdash;{$dates[1]|escape}
											{/if}
											{if $publicationDate->isHijriCalendar()}
												<div class="hijri">
													{translate key="common.dateHijri"}
												</div>
											{/if}
										</div>
									</div>
								{/foreach}
							{/if}

							{* PubIDs *}
							{foreach from=$pubIdPlugins item=pubIdPlugin}
								{assign var=pubIdType value=$pubIdPlugin->getPubIdType()}
								{assign var=storedPubId value=$publicationFormat->getStoredPubId($pubIdType)}
								{if $storedPubId != ''}
									<div class="sub_item pubid {$publicationFormat->getId()|escape}">
										<h2 class="label">
											{$pubIdType}
										</h2>
										<div class="value">
											{$storedPubId|escape}
										</div>
									</div>
								{/if}
							{/foreach}

							{* DOIs *}
							{assign var=publicationFormatDoiObject value=$publicationFormat->getData('doiObject')}
							{if $publicationFormatDoiObject}
								{assign var="doiUrl" value=$publicationFormatDoiObject->getData('resolvingUrl')|escape}
								<div class="sub_item pubid {$publicationFormat->getId()|escape}">
									<h2 class="label">
										{translate key="doi.readerDisplayName"}
									</h2>
									<div class="value">
										<a href="{$doiUrl}">
											{$doiUrl}
										</a>
									</div>
								</div>
							{/if}

							{* Physical dimensions *}
							{if $publicationFormat->getPhysicalFormat()}
								<div class="sub_item dimensions">
									<h2 class="label">
										{translate key="monograph.publicationFormat.productDimensions"}
									</h2>
									<div class="value">
										{$publicationFormat->getDimensions()|escape}
									</div>
								</div>
							{/if}
						</div>
					{/if}
				{/foreach}
			{/if}

         </div>
        <div class="book-praise"
        v-bind="{ 'shown': infoType === 'praise', 'hidden': infoType !== 'praise' }"
        >
          praise
        </div>
      </div>


</div>
