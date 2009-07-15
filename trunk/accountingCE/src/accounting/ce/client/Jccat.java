package accounting.ce.client;

import org.apache.commons.lang.StringUtils;

import accounting.ce.client.auto._Jccat;

/**
 * A persistent class mapped as "Jccat" Cayenne entity.
 */
public class Jccat extends _Jccat {

	public void setBudgetAmount(int type, Double amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget" + type + "Amount", false);
        }
        
        Object oldValue = null;
        switch(type) {
        case 0:
        	oldValue = this.budget0Amount;
            this.budget0Amount = amount;
            break;
        case 1:
        	oldValue = this.budget1Amount;
            this.budget1Amount = amount;
            break;
        case 2:
        	oldValue = this.budget2Amount;
            this.budget2Amount = amount;
            break;
        case 3:
        	oldValue = this.budget3Amount;
            this.budget3Amount = amount;
            break;
        case 4:
        	oldValue = this.budget4Amount;
            this.budget4Amount = amount;
            break;
        case 5:
        	oldValue = this.budget5Amount;
            this.budget5Amount = amount;
            break;
        case 6:
        	oldValue = this.budget6Amount;
            this.budget6Amount = amount;
            break;
        case 7:
        	oldValue = this.budget7Amount;
            this.budget7Amount = amount;
            break;
        case 8:
        	oldValue = this.budget8Amount;
            this.budget8Amount = amount;
            break;
        case 9:
        	oldValue = this.budget9Amount;
            this.budget9Amount = amount;
            break;
        case 10:
        	oldValue = this.budget10Amount;
            this.budget10Amount = amount;
            break;
        case 11:
        	oldValue = this.budget11Amount;
            this.budget11Amount = amount;
            break;
        case 12:
        	oldValue = this.budget12Amount;
            this.budget12Amount = amount;
            break;
        case 13:
        	oldValue = this.budget13Amount;
            this.budget13Amount = amount;
            break;
        case 14:
        	oldValue = this.budget14Amount;
            this.budget14Amount = amount;
            break;
        case 15:
        	oldValue = this.budget15Amount;
            this.budget15Amount = amount;
            break;
        case 16:
        	oldValue = this.budget16Amount;
            this.budget16Amount = amount;
            break;
        }
        
        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget" + type + "Amount", oldValue, amount);
        }
	}
	
	public Double getBudgetAmount(int type) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget" + type + "Amount", false);
        }
        
        switch(type) {
        case 0:
        	return this.budget0Amount;
        case 1:
        	return this.budget1Amount;
        case 2:
        	return this.budget2Amount;
        case 3:
        	return this.budget3Amount;
        case 4:
        	return this.budget4Amount;
        case 5:
        	return this.budget5Amount;
        case 6:
        	return this.budget6Amount;
        case 7:
        	return this.budget7Amount;
        case 8:
        	return this.budget8Amount;
        case 9:
        	return this.budget9Amount; 
        case 10:
        	return this.budget10Amount;
        case 11:
        	return this.budget11Amount;
        case 12:
        	return this.budget12Amount;
        case 13:
        	return this.budget13Amount;
        case 14:
        	return this.budget14Amount;
        case 15:
        	return this.budget15Amount;
        default:
        	return this.budget16Amount;
        }
	}
	
	public void setName(String name) {
		super.setName(StringUtils.left(name, 30));
	}
	
}
