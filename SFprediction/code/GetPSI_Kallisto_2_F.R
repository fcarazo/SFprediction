#' GetPSI_Kallisto
#' 
#' @description Get the values of PSI.A filer expresion is applied if 
#' the user select the option of filter.
#' 
#' @param PathsxTranscript the outpu of EventGTFfromTrancriptomeGTF
#' @param Samples the samples (in the rowname of the samples must be written only the name of the transcript)
#' @param Filter Boolean variable to indicate if an expression filter is applied. Defaul T
#' @param Qn Quantile used to filter the events (Bounded between 0-1, Q1 would be 0.25).
#' 



GetPSI_Kallisto_2_F <- function(PathsxTranscript,Samples,Filter=T,Qn=0.25){
  
  
  
  
  Path1 <- PathsxTranscript$ExTP1
  Path2 <- PathsxTranscript$ExTP2
  PathRef <- PathsxTranscript$ExTPRef
  
  ## check that the columns of the pathxTrans is the same in Transxsample
  trannames_Samples <- rownames(Samples)
  
  trannames_gtf <- PathsxTranscript$transcritnames
  
  
  if(any(trannames_Samples%in%trannames_gtf==F)){
    stop("\nTranscripts in the Sample that are not in the reference GTF\n")
  }
  
  if(any(trannames_gtf%in%trannames_Samples==F)){
    stop("\nTranscripts in the GTF that are not in the Sample\n")
  }
  
  
  if(length(trannames_Samples)!=length(trannames_gtf)){
    stop("\nNot the same number of Transcripts...\n")
  }
  
  if (!identical(trannames_gtf,trannames_Samples)){
    iix <-match(trannames_gtf,trannames_Samples)
    Samples<-Samples[iix,]
  }
  
  
  ConcentrationPath1 <- as.matrix(Path1%*%Samples)
  ConcentrationPath2 <- as.matrix(Path2%*%Samples)
  ConcentrationPathRef <- as.matrix(PathRef%*%Samples)
  
  if (Filter){
    Min_p1 <- rowMins(ConcentrationPath1)
    Min_p2 <- rowMins(ConcentrationPath2)
    Min_pRef <- rowMins(ConcentrationPathRef)
    
    Max_p1 <- rowMaxs(ConcentrationPath1)
    Max_p2 <- rowMaxs(ConcentrationPath2)
    Max_pRef <- rowMaxs(ConcentrationPathRef)
    
    names(Min_p1)<- names(Min_p2)<- names(Max_pRef)<- names(Max_p1)<- names(Max_p2)<-names(Min_pRef)<-rownames(ConcentrationPath1)
    
    Qt_p1 <- rowQuantiles(ConcentrationPath1,  probs = 0.8)
    Qt_p2 <-  rowQuantiles(ConcentrationPath2,  probs = 0.8)
    
    th_p <- quantile(c(Max_p1, Max_p2),Qn)
    th_pRef <- quantile(Max_pRef,Qn)
    
    Filt <- which((Min_pRef > th_pRef) & (Qt_p1 > th_p) & (Qt_p2 > th_p))
    
    
    ConcentrationPath1<-ConcentrationPath1[Filt,]
    ConcentrationPath2<-ConcentrationPath2[Filt,]
    ConcentrationPathRef<-ConcentrationPathRef[Filt,]
    
    PSI <- ConcentrationPath1/ConcentrationPathRef
    
    ExpEvs <- vector(mode="list",length = dim(ConcentrationPath1)[1])
    names(ExpEvs) <- rownames(ConcentrationPath1)
    
    matsamples <- matrix(0,nrow=dim(ConcentrationPath1)[2],ncol=3)
    colnames(matsamples)<-c("P1","P2","PRef")
    rownames(matsamples)<-colnames(ConcentrationPath1)
    
    for (i in 1:dim(ConcentrationPath1)[1]){
      matsamples[,1]<-ConcentrationPath1[i,]
      matsamples[,2]<-ConcentrationPath2[i,]
      matsamples[,3]<-ConcentrationPathRef[i,]
      ExpEvs[[i]]<-matsamples
    }
    
    Result <- list(PSI=PSI,ExpEvs=ExpEvs)
    return(Result)
    
  } else{
    
    PSI <- ConcentrationPath1/ConcentrationPathRef
    
    ExpEvs <- vector(mode="list",length = dim(ConcentrationPath1)[1])
    names(ExpEvs) <- rownames(ConcentrationPath1)
    
    matsamples <- matrix(0,nrow=dim(ConcentrationPath1)[2],ncol=3)
    colnames(matsamples)<-c("P1","P2","PRef")
    rownames(matsamples)<-colnames(ConcentrationPath1)
    
    for (i in 1:dim(ConcentrationPath1)[1]){
      matsamples[,1]<-ConcentrationPath1[i,]
      matsamples[,2]<-ConcentrationPath2[i,]
      matsamples[,3]<-ConcentrationPathRef[i,]
      ExpEvs[[i]]<-matsamples
    }
    
    Result <- list(PSI=PSI,ExpEvs=ExpEvs)
    return(Result)
    
  }
  
}
